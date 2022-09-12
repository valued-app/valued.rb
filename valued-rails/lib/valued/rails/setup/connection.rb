# frozen_string_literal: true

module Valued::Rails::Setup
  class Connection
    DEFAULTS = {
      endpoint: Valued::Connection::DEFAULT_ENDPOINT
    }
    
    EXECUTORS = {
      single_thread:      Concurrent::SingleThreadExecutor,
      cached_thread_pool: Concurrent::CachedThreadPool,
      thread_pool:        Concurrent::ThreadPoolExecutor,
      immediate:          Concurrent::ImmediateExecutor,
    }

    DEFAULT_LOOKUP = [:env, :credentials, :config, :default]
    
    private_constant :DEFAULTS, :EXECUTORS, :DEFAULT_LOOKUP

    # @api private
    def initialize
      @client          = nil
      @explicit_client = false
      @options         = {}
    end

    # @!attribute [rw] token
    def token = get(:token)
    def token=(*value, &block)
      set(:token, [block, *value])
    end

    # @return [true, false] Whether the token is set.
    def token? = !!token

    # @!attribute [rw] endpoint
    def endpoint = get(:endpoint)
    def endpoint=(*value, &block)
      set(:endpoint, [block, *value])
    end

    # @return [true, false] Whether the endpoint is set.
    def endpoint? = !!endpoint

    # @!attribute [rw] executor
    def executor = Valued::Connection.executor
    def executor=(*args)
      executor, *args = args.flatten
      was = executor

      case executor
      when Symbol then executor       = EXECUTORS.fetch(executor) { raise ArgumentError, "unknown executor: #{executor}" }
      when Hash   then executor, args = executor.delete(:mode), [args, executor]
      when String then executor       = executor.to_sym
      when Class  then executor       = executor.new(*args)
      end
  
      return self.executor = [executor, args] unless was == executor
      raise ArgumentError, "Invalid executor: #{executor.inspect}" if executor and !executor.respond_to?(:post)
      Valued::Connection.executor = executor
    end

    # @!attribute [rw] backend
    attr_reader :backend
    def backend=(value = nil, &block)
      if value ||= block
        raise RuntimeError, "Cannot set #{key} when explicitly setting a client" if explicit_client?
        raise ArgumentError, "Invalid backend: #{value.inspect}" unless value.respond_to?(:call)
        @backend = value
      else
        @backend = nil
      end
      @client = nil
    end

    # @return [true, false] Whether the backend is set.
    def backend? = !!@backend

    # @!attribute [rw] client
    # @return [Valued::Client]
    def client
      @client ||= if token? or backend?
        case backend
        when nil  then Valued::Client.new(token, endpoint)
        when Proc then Valued::Client.new(Valued::Connection.new(token, endpoint), &backend)
        else Valued::Client.new(backend)
        end
      elsif Valued.connected?
        Valued.client
      end
    end

    def client=(value)
      if value
        raise RuntimeError, "Cannot set client when explicitly setting a backend" if backend
        raise RuntimeError, "Cannot set client when explicitly setting #{@options.compact.keys.first}" if @options.compact.any?
        @explicit_client = true
        @client = Valued::Client.new(value)
      else
        @explicit_client = false
        @client = nil
      end
    end

    # @return [true, false] Whether a client can be created from the current options.
    def client? = !!client

    # @return [true, false] Whether the client was explicitly set.
    def explicit_client? = @explicit_client

    private

    def get(key) = @options.fetch(key) { @options[key] = find(key, DEFAULT_LOOKUP) }

    def set(key, value)
      raise RuntimeError, "Cannot set #{key} when explicitly setting a client" if explicit_client?
      @options[key] = find(key, value)
      @client = nil
    end

    def find(key, value)
      case value
      when Array        then find(key, value.map { find(key, _1) }.compact.first)
      when Proc         then find(key, value.call)
      when :env         then find(key, ENV["VALUED_#{key.upcase}"])
      when :config      then find(key, config[key])
      when :credentials then Rails.application.credentials.dig(:valued, key)
      when :default     then DEFAULTS[key]
      else value.presence
      end
    end

    def config
      @config ||= Rails.application.config_for(:valued)
    rescue RuntimeError => error
      raise error unless error.message.include? "Could not load configuration. No such file"
      @config = {}
    end
  end
end