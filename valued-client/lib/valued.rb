require "json"
require "net/http"
require "concurrent"
require "date"
require "time"

module Valued
  require "valued/helpers"
  require "valued/client"
  require "valued/connection"
  require "valued/scope"

  extend Helpers

  def self.connect(...)
    @client = Client.new(...)
    @scope  = Scope.new(@client)
    @client
  end

  def self.client
    return @client if defined? @client and @client
    raise RuntimeError, "Need to call Valued.connect before Valued.client"
  end

  def self.scope(data = nil, &block)
    raise RuntimeError, "Need to call Valued.connect before Valued.scope" unless defined? @scope and @scope
    return @scope unless data || block
    block ? @scope.scope(data, &block) : @scope.apply(data)
  end

  def self.reset = scope.reset
end