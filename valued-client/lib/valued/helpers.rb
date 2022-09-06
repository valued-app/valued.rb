module Valued::Helpers
  def with(...) = scope(...)

  def []=(*key, value)
    scope.scope(key => value)
  end

  def [](*key) = scope.to_h.dig(*Valued::Data.normalize_keys(key))

  def user = scope.to_h["user"]
  def user=(value)
    self["user"] = value
  end

  def user_id = scope.to_h.dig("user", "id")
  def user_id=(value)
    self["user.id"] = value
  end

  def customer = scope.to_h["customer"]
  def customer=(value)
    self["customer"] = value
  end

  def customer_id = scope.to_h.dig("customer", "id")
  def customer_id=(value)
    self["customer.id"] = value
  end

  def action(key, data = {}) = scope.client.action(key, scope.merge(data))

  def pageview(url, data = {}) = scope.client.pageview(url, scope.merge(data))
  alias_method :page_view, :pageview

  def sync(data = nil)
    return scope.client.sync(scope.merge(data)) if data && data.any?
    sync_user if user_id && user.keys.size > 1
    sync_costumer if customer_id && customer.keys.size > 1
  end
  
  def sync_user(data = {}) = scope.client.sync_user(user.to_h.merge(data))
  def sync_customer(data = {}) = scope.client.sync_customer(customer.to_h.merge(data))
end