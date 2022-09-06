# Helper class to incrementially build up event data.
#
# @example
#   scope = Valued::Scope.new(client)
#   scope["user.id"] = 123
#   
#   # user nagivates to customer with id 12
#   scope.with("customer.id" => 12) do
#     scope.page_view("https://big.company.com/reports/12")
#     scope.action("report.generated")
#   end
#   
#   # trigger an action without a customer
#   scope.page_view("https://big.company.com/profile")
#   scope.action("profile.updated")
class Valued::Scope
  include Valued::Helpers

  # @return [Valued::Client] The client to use.
  attr_reader :client

  # @return [Hash] Default data to initialize the scope with and to fall back to after a {#reset}.
  attr_reader :defaults

  # @param client [Valued::Client] The client to use. See {#client}.
  # @param defaults [Hash] Default data to initialize the scope with and to fall back to after a {#reset}. See {#defaults}.
  def initialize(client, data = {})
    @defaults = Valued::Data.normalize(data)
    @store    = Concurrent::ThreadLocalVar.new(@defaults)
    @client   = Valued::Client.new(client)
  end

  # Resets the scope to the default data.
  # @return [void]
  def reset = @store.value = @defaults

  # @overload scope
  #   @return [self]
  #
  # @overload scope(data)
  #   Applies the given data to the current scope.
  #
  #   @example
  #     scope = Valued::Scope.new(client, a: 1)
  #     
  #     scope.scope(b: 2)
  #     scope.to_h # => { "a" => 1, "b" => 2 }
  #     
  #     scope.reset
  #     scope.to_h # => { "a" => 1 }
  #
  #   @param data [Hash] The data to apply.
  #   @return [self]
  #
  # @overload scope(data = nil)
  #   Creates a nested scope execution. Changes to the scope are reverted after the block has been executed.
  #
  #   @example
  #     scope = Valued::Scope.new(client, a: 1)
  #      
  #     scope.scope(b: 2) do
  #       scope.to_h # => { "a" => 1, "b" => 2 }
  #     end
  #     
  #     scope.to_h # => { "a" => 1 }
  #
  #   @see Helpers#with
  #   @param data [Hash, nil] The data to apply only to the nested scope.
  #   @yield [self] Yields the scope to the block.
  def scope(data = nil, &block)
    return self unless data || block
    data_was = @store.value if block
    @store.value = Valued::Data.merge(to_h, Valued::Data.normalize(data)) if data && !data.empty?
    block ? yield(self) : self
  ensure
    @store.value = data_was if data_was
  end

  # @return [Hash] The current scope data.
  def to_h = @store.value
  
  # @param data [Hash, Scope] The data to apply.
  # @return [Hash] The current scope data merged with the given argument.
  def merge(data) = to_h.merge(Valued::Data.normalize(data))
end
