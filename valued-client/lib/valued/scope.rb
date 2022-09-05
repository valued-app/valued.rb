require "valued"

class Valued::Scope
  include Valued::Helpers

  attr_reader :client

  attr_reader :defaults

  def initialize(client, data = {})
    @defaults = Valued::Data.normalize(data)
    @store    = Concurrent::ThreadLocalVar.new(@defaults)
    @client   = Valued::Client.new(client)
  end

  def reset = @store.value = @defaults

  def scope(data = nil, &block)
    return self unless data || block
    data_was = @store.value if block
    @store.value = Valued::Data.merge(to_h, Valued::Data.normalize(data)) if data && !data.empty?
    block ? yield(self) : self
  ensure
    @store.value = data_was if data_was
  end

  def to_h = @store.value
  def merge(data) = to_h.merge(Valued::Data.normalize(data))
end