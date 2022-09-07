# frozen_string_literal: true

# This class does low-level connection handling:
# * Convert input arguments to a connection callback, via {Valued::Connection.build}.
# * Implement the default connection callback, via {Valued::Connection#call}.
# * Wrap background processing for sending requests, in order to avoid blocking the current thread.
#
# @api private
class Valued::Connection
  MUTEX    = Thread::Mutex.new
  ENV_KEYS = %w[VALUED_ENV RAILS_ENV APP_ENV RACK_ENV ENV]
  private_constant :MUTEX, :ENV_KEYS

  # Default HTTP endpoint to send event payloads to.
  DEFAULT_ENDPOINT = URI("https://ingres.valued.app/events")

  # @return [String] Token to authenticate against the Valued API with.
  attr_reader :token
  
  # @return [URI] HTTP endpoint to send event payloads to.
  attr_reader :endpoint
  
  # @return [Hash{String => String}] HTTP headers to send with every request.
  attr_reader :headers

  # Executes a connection callback in a background executor.
  # @param connection [Valued::Connection, #call] The connection callback to execute.
  # @param data [Hash] The data to send.
  # @return [void]
  # @see #executor
  def self.call(connection, data) = executor.post { connection.call(data) }

  # @return [Concurrent::Executor, #pool] executor used to send requests in the background
  # @see https://ruby-concurrency.github.io/concurrent-ruby/master/file.thread_pools.html
  def self.executor
    return @executor if defined?(@executor) && @executor
    MUTEX.synchronize do
      @executor ||= case environment
        when "development" then Concurrent::SingleThreadExecutor.new
        when "test" then Concurrent::ImmediateExecutor.new
        else Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: 10, max_queue: 0, fallback_policy: :caller_runs)
        end
    end
  end

  # Explicitely sets the executor used to send requests in the background.
  # @param [Concurrent::Executor, #pool] executor used to send requests in the background
  # @note Changing the executor is not thread-safe. It should be done before any requests are sent.
  # @see https://ruby-concurrency.github.io/concurrent-ruby/master/file.thread_pools.html
  # @return [void]
  def self.executor=(executor)
    @executor = executor
  end

  # Checks multiple known environment variables to determine the current environment (like `RAILS_ENV` or `RACK_ENV`).
  # Used to set the default executor.
  # @return [String, nil] environment name, or `nil` if none is found
  # @see .executor
  def self.environment = ENV_KEYS.each { return ENV[_1] if ENV[_1].to_s != "" }


  # @overload build(token, endpoint = DEFAULT_ENDPOINT)
  #   @param token [String] The Valued API token.
  #   @param endpoint [String, URI] The Valued API endpoint.
  #   @return [#call] A connection callback.
  #
  # @overload build(callback)
  #   @param callback [Proc, #call] A connection callback.
  #   @return [#call] A connection callback.
  #
  # @overload build(*args, &block)
  #   @param args [Array] The arguments to pass to the block, after the data argument.
  #   @yield [data, *args] For each request, calls the callback with the data to be sent and the arguments.
  #   @yieldparam data [Hash] The data to be sent.
  #   @yieldparam args [Array] The arguments passed to {Valued::Connection.build}.
  #   @return [#call] A connection callback.
  def self.build(*args, &block)
    return Proc.new { |data| block.call(data, *args) } if block
    case args
    in [String => token] then new(token, DEFAULT_ENDPOINT)
    in [String, String | URI] then new(*args)
    in [callback] if callback.respond_to? :call then callback
    end
  end

  # @param token [String] Valued API token
  # @param endpoint [String, URI] Valued API endpoint
  # @see Valued::Connection.build
  def initialize(token, endpoint)
    @token = token
    @endpoint = URI(endpoint)
    @headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{token}",
      "User-Agent" => "valued-client/#{Valued::VERSION} (Ruby/#{RUBY_VERSION})",
    }
  end

  # Sends data to the Valued API.
  # @param data [Hash]
  # @return void
  # @todo Error handling
  def call(data) = Net::HTTP.post(endpoint, data.to_json, headers)
  
  # Display connection object in Ruby console, error messages, etc.
  # Avoids outputting the token.
  # @private
  def inspect = "#<#{self.class} #{endpoint.inspect}>"
end