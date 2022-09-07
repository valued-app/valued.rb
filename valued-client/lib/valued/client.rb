# frozen_string_literal: true

# Client objects can be used directly (or indirectly, via {Scope}, {Helpers}, or {Valued}) to send events to the Valued event ingestions API.
#
# @example
#   client = Valued::Client.new(token)
#
#   # Send a user.created action even to Valued
#   client.action("user.created", user: { id: 1 })
class Valued::Client
  # @return [Valued::Connection, #call] connection objected called every time data is to be sent to the Valued API
  # @api private
  attr_reader :connection

  # @see #initialize
  # @return [Valued::Client] either a new client or the client passed in as argument
  def self.new(*args) = args.first.is_a?(Valued::Client) ? args.first : super

  # @overload initialize(token)
  #   @param token [String] The Valued API token.
  #
  # @overload initialize(client)
  #   @param client [Valued::Client] A Valued client.
  #
  # @overload initialize(token, endpoint)
  #   @param token [String] The Valued API token.
  #   @param endpoint [String, URI] The Valued API endpoint.
  #
  # @overload initialize(callback)
  #   @param callback [Proc, #call] A connection callback.
  #
  # @overload initialize(*args, &block)
  #   @param args [Array] The arguments to pass to the block, after the data argument.
  #   @yield [data, *args] For each request, calls the callback with the data to be sent and the arguments.
  #   @yieldparam data [Hash] The data to be sent.
  #   @yieldparam args [Array] The arguments passed to {Valued::Client.new}.
  def initialize(...) = @connection = Valued::Connection.build(...)

  # Tracks a page view event.
  # @param url [String, URI] The URL of the page.
  # @param data [Hash, Scope] The data to send with the event.
  # @return [void]
  def pageview(url = nil, data)
    data = Valued::Data.merge(data, "attributes.source.url" => url) if url
    raise ArgumentError, "Missing data hash" if url.nil? && !data.is_a?(Hash)
    send_event("pageview", data)
  end

  alias_method :page_view, :pageview

  # Tracks an action event.
  # @param key [String] The action key.
  # @param data [Hash, Scope] The data to send with the event.
  # @return [void]
  def action(key, data) = send_event("action", data.merge("key" => key))

  # Sends a sync event.
  # @param data [Hash, Scope] The data to send with the event.
  # @return [void]
  def sync(data) = send_event("sync", data)

  # Sends a sync event for the user data.
  # @param data [Hash, Scope] The user data to send with the event.
  # @return [void]
  def sync_user(data) = sync("user" => data)
  
  # Sends a sync event for the customer data.
  # @param data [Hash, Scope] The customer data to send with the event.
  # @return [void]
  def sync_customer(data) = sync("customer" => data)

  private

  def send_event(category, data)
    data = Valued::Data.validate(data.merge("category" => category)) { raise ArgumentError, _1 }
    data = data.merge("occured_at" => Time.now.iso8601) unless data["occured_at"]
    Valued::Connection.call(connection, data)
  end
end
