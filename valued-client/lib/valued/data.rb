module Valued::Data
  extend self

  REGISTER = {}
  private_constant :REGISTER

  def register(type, &block) = REGISTER[type] = block

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

  def valid?(data) = !!validate(data) { return false }

  def normalize(data)
    case data
    when Valued::Scope        then data.to_h
    when Hash                 then data.inject({}) { |h, (k, v)| set(h, k, v) }.freeze
    when Array                then data.map { normalize(_1) }.freeze
    when Symbol               then data.name
    when Time, DateTime, Date then data.iso8601
    else
      return normalize(data.to_valued_data) if data.respond_to?(:to_valued_data)
      data.class.ancestors.each do |type|
        next unless callback = REGISTER[type]
      end
    end
  end

  private

  def merge(data, new_data)
    data.merge(new_data) do |key, old_value, new_value|
      new_value = merge(old_value, new_value) if old_value.is_a?(Hash) && new_value.is_a?(Hash)
      new_value
    end.freeze
  end

  private

  def validate_action(data)
    yield("Missing user or customer") unless data["user"] || data["customer"]
    yield("Customer data is missing an id") if data["customer"] && !data["customer"]["id"]
    yield("User data is missing an id") if data["user"] && !data["user"]["id"]
  end

  def validate_pageview(data)
    yield("Missing user") unless data["user"] && data["user"]["id"]
    yield("Missing attributes") unless data["attributes"]
    yield("Missing attributes.url") unless data["attributes"]["url"]
  end

  def validate_sync(data)
    yield("Missing user or customer") unless data["user"] || data["customer"]
    yield("Cannot include both user and customer") unless data["user"] ** data["customer"]
  end
  
  def normalize_keys(*keys)
    keys.flatten.flat_map { _1.to_s.split(".") }
  end

  def set(data, key, value)
    *parents, key = normalize_keys(key)
    parents.inject(data) { _1[_2] ||= {} }[key] = normalize(value)
    data
  end
end