class Valued::Client
  # @return [Valued::Connection, #call] connection objected called every time data is to be sent to the Valued API
  # @api private
  attr_reader :connection

  # @overload new(token)
  #   @param token [String] The Valued API token.
  #   @return [Valued::Client] A new client.
  #
  # @overload new(client)
  #   @param client [Valued::Client] A Valued client.
  #   @return [Valued::Client] The client passed in.
  #
  # @overload new(token, endpoint)
  #   @param token [String] The Valued API token.
  #   @param endpoint [String, URI] The Valued API endpoint.
  #   @return [Valued::Client] A new client.
  #
  # @overload new(callback)
  #   @param callback [Proc, #call] A connection callback.
  #   @return [Valued::Client] A new client.
  #
  # @overload new(*args, &block)
  #   @param args [Array] The arguments to pass to the block, after the data argument.
  #   @yield [data, *args] For each request, calls the callback with the data to be sent and the arguments.
  #   @yieldparam data [Hash] The data to be sent.
  #   @yieldparam args [Array] The arguments passed to {Valued::Client.new}.
  #   @return [Valued::Client] A new client.
  def self.new(*args) = args.first.is_a?(Valued::Client) ? args.first : super

  # @private
  def initialize(...) = @connection = Valued::Connection.build(...)

  def pageview(url = nil, data)
    data = Valued::Data.merge(data, "attributes.source.url" => url) if url
    raise ArgumentError, "Missing data hash" if url.nil? && !data.is_a?(Hash)
    send_event("pageview", data)
  end

  alias_method :page_view, :pageview

  def action(key, data) = send_event("action", data.merge("key" => key))
  def sync(data) = send_event("sync", data)

  # @todo some smarter user data collection here
  def sync_user(data) = sync("user" => data)
  
  # @todo some smarter customer data collection here
  def sync_customer(data) = sync("customer" => data)
    

  private

  def send_event(category, data)
    data = Valued::Data.validate(data.merge("category" => category)) { raise ArgumentError, _1 }
    data = data.merge("occured_at" => Time.now.iso8601) unless data["occured_at"]
    Valued::Connection.call(connection, data)
  end
end