# frozen_string_literal: true

# Module to deal with data normalization, validation, and merging.
# Used internally.
module Valued::Data
  extend self

  REGISTER = {}
  private_constant :REGISTER

  # Registers normalization logic for a given class.
  #
  # @example
  #   Valued::Data.register(User) { |user| user.to_h }
  #
  # @param type [Class, Module] the class to register normalization logic for
  # @yield [object] the normalization logic
  # @yieldparam object [Object] the object to normalize (which will be a instance of `type`)
  # @yieldreturn [Object] the partially normalized data – will be run through `Valued::Data.normalize` again
  # @!scope class
  def register(type, &block) = REGISTER[type] = block

  # Normalizes and validates data.
  #
  # @example
  #   Valued::Data.validate("user.id" => 1) { raise "invalid payload: #{_1}" }
  #
  # @param data [Object] the data to normalize and validate
  # @yield [error] called for every validation error
  # @yieldparam error [String] the error message
  # @return [Object] the normalized data
  # @!scope class
  def validate(data, &block)
    data = normalize(data)
    case data["category"]
    when "action"   then validate_action(data, &block)
    when "pageview" then validate_pageview(data, &block)
    when "sync"     then validate_sync(data, &block)
    when nil        then yield("Missing category")
    else yield("Unknown category: #{data["category"]}")
    end
    data
  end

  # @return [true, false] Wether or not the given data is valid.
  # @param data [Object] the data to validate
  # @see .validate
  # @!scope class
  def valid?(data) = !!validate(data) { return false }

  # Normalizes data.
  #
  # @example
  #   Valued::Data.normalize("user.id" => 1)
  #   # => { "user" => { "id" => 1 } }
  #
  # @param data [Object] the data to normalize
  # @return [Object] the normalized data
  # @!scope class
  def normalize(data)
    case data
    when String                        then data.frozen? ? data : data.dup.freeze
    when Integer, true, false          then data
    when Valued::Scope                 then data.to_h
    when Hash                          then data.inject({}) { |h, (k, v)| set(h, k, v) }.freeze
    when Concurrent::Map               then normalize(data.each_pair.to_h)
    when Array, Set, Concurrent::Tuple then data.map { normalize(_1) }.freeze
    when Symbol                        then data.name
    when Time, DateTime, Date          then data.iso8601.freeze
    else
      return normalize(data.to_valued_data) if data.respond_to?(:to_valued_data)
      data.class.ancestors.each do |type|
        next unless callback = REGISTER[type]
        return normalize(callback.call(data))
      end
      data
    end
  end

  # Deep merges two hashes.
  #
  # @api private
  # @!scope class
  def merge(data, new_data)
    data.merge(new_data) do |key, old_value, new_value|
      new_value = merge(old_value, new_value) if old_value.is_a?(Hash) && new_value.is_a?(Hash)
      new_value
    end.freeze
  end

  # Turns a key or list of keys into a normalized list of keys for nesting.
  # 
  # @example
  #   Valued::Data.normalize_keys("user.id") # => ["user", "id"]
  #
  # @api private
  # @!scope class
  def normalize_keys(*keys)
    keys.flatten.flat_map { _1.to_s.split(".") }
  end

  private

  def validate_action(data)
    yield("Missing user.id or customer.id") unless data.dig("user", "id") || data.dig("customer", "id")
  end

  def validate_pageview(data)
    yield("Missing user.id") unless data.dig("user", "id")
    yield("Missing attributes.url") unless data.dig("attributes", "source", "url")
  end

  def validate_sync(data)
    yield("Missing user.id or customer.id") unless data.dig("user", "id") || data.dig("customer", "id")
    yield("Cannot include both user and customer") if data["user"] && data["customer"]
  end

  def set(data, key, value)
    *parents, key = normalize_keys(key)
    parents.inject(data) { _1[_2] ||= {} }[key] = normalize(value)
    parents.inject(data) { _1[_2].freeze }
    data
  end
end
