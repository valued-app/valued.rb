# frozen_string_literal: true

# Common convenience methods shared between {Valued} and {Valued::Scope}.
module Valued::Helpers
  # Creates a nested scope. Changes done to the data in the nested scope are
  # not reflected in the parent scope.
  #
  # @example
  #   scope.user_id # => nil
  #
  #   scope.with("user.id" => 1) do
  #     scope.user_id # => 1
  #     scope.user_id = 2
  #     scope.user_id # => 2
  #   end
  #
  #   scope.user_id # => nil
  def with(...) = scope(...)

  # Stores the given data in the scope.
  # @example
  #   # there are all more or less equivalent
  #   scope["user.id"]  = 1
  #   scope[:user, :id] = 1
  #   scope["user"]     = { id: 1 }
  #
  # @param key [String, Symbol] The keys to store the data under.
  # @param value [Object] The value to store.
  # @return [void]
  def []=(*key, value)
    scope.scope(key => value)
  end

  # Reads a stored value.
  #
  # @example
  #   scope.user_id = 1
  #   scope[:user]      # => { "id" => 1 }
  #   scope[:user, :id] # => 1
  #   scope["user.id"]  # => 1
  #
  # @param key [String, Symbol] The keys to looku up the the data under.
  def [](*key) = scope.to_h.dig(*Valued::Data.normalize_keys(key))

  # @!attribute [rw] user
  # @return [Hash] The user data.
  def user = scope.to_h["user"]
  def user=(value)
    self["user"] = value
  end

  # @!attribute [rw] user_id
  # @return [String, Integer] The user id.
  def user_id = scope.to_h.dig("user", "id")
  def user_id=(value)
    self["user.id"] = value
  end

  # @!attribute [rw] customer
  # @return [Hash] The customer data.
  def customer = scope.to_h["customer"]
  def customer=(value)
    self["customer"] = value
  end

  # @!attribute [rw] customer_id
  # @return [String, Integer] The customer id.
  def customer_id = scope.to_h.dig("customer", "id")
  def customer_id=(value)
    self["customer.id"] = value
  end

  # (see Valued::Client#action)
  def action(key, data = {}) = scope.client.action(key, scope.merge(data))

  # (see Valued::Client#pageview)
  def pageview(url, data = {}) = scope.client.pageview(url, scope.merge(data))
  alias_method :page_view, :pageview

  # (see Valued::Client#sync)
  def sync(data = nil)
    return scope.client.sync(scope.merge(data)) if data && data.any?
    sync_user if user_id && user.keys.size > 1
    sync_costumer if customer_id && customer.keys.size > 1
  end
  
  # (see Valued::Client#sync_user)
  def sync_user(data = {}) = scope.client.sync_user(user.to_h.merge(data))

  # (see Valued::Client#sync_customer)
  def sync_customer(data = {}) = scope.client.sync_customer(customer.to_h.merge(data))
end
