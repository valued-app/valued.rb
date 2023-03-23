# frozen_string_literal: true

require "json"
require "net/http"
require "concurrent"
require "date"
require "time"

# Top-level module for the valued-client gem.
module Valued
  require "valued/helpers"
  require "valued/client"
  require "valued/data"
  require "valued/connection"
  require "valued/scope"
  require "valued/version"

  extend Helpers

  # Creates a shared connection that can be used directly via Valued.
  #
  # @example
  #   Valued.connect(token)
  #   
  #   # Wrap this in a scope so we don't leak a user id.
  #   Valued.scope do
  #     Valued["user.id"] = 123
  #   
  #     # user nagivates to customer with id 12
  #     Valued.with("customer.id" => 12) do
  #       Valued.page_view("https://big.company.com/reports/12")
  #       Valued.action("report.generated")
  #     end
  #   
  #     # trigger an action without a customer
  #     Valued.page_view("https://big.company.com/profile")
  #     Valued.action("profile.updated")
  #   end
  #
  # @overload connect(token)
  #   @param token [String] The Valued API token.
  #
  # @overload connect(client)
  #   @param client [Valued::Client] A Valued client.
  #
  # @overload connect(token, endpoint)
  #   @param token [String] The Valued API token.
  #   @param endpoint [String, URI] The Valued API endpoint.
  #
  # @overload connect(callback)
  #   @param callback [Proc, #call] A connection callback.
  #
  # @overload connect(*args, &block)
  #   @param args [Array] The arguments to pass to the block, after the data argument.
  #   @yield [data, *args] For each request, calls the callback with the data to be sent and the arguments.
  #   @yieldparam data [Hash] The data to be sent.
  #   @yieldparam args [Array] The arguments passed to {Valued::Client.new}.
  #
  # @return [Valued::Client] The client that will be used.
  def self.connect(...)
    @client = Client.new(...)
    @scope  = Scope.new(@client)
    @client
  end

  # Removes the shared connection.
  # @return [void]
  def self.disconnect = @client = @scope = nil

  # @return [true, false] whether a shared connection has been created
  def self.connected? = !!@client

  # @return [Valued::Client] the shared client
  # @see .connect
  def self.client
    return @client if defined? @client and @client
    raise RuntimeError, "Need to call Valued.connect before Valued.client"
  end

  # @overload scope
  #   @return [Valued::Scope] the shared scope
  #   @see .connect
  #
  # @overload scope(data)
  #   Applies the given data to the current scope.
  #
  #   @example
  #     Valued.scope("user.id" => 123)
  #     Valued.user_id # => 123
  #
  #   @param data [Hash] The data to apply.
  #   @return [Valued::Scope] the shared scope
  #
  # @overload scope(data = nil)
  #   Creates a nested scope execution. Changes to the scope are reverted after the block has been executed.
  #
  #   @example
  #     Valued.scope("user.id" => 1) do
  #       Valued.user_id # => 1
  #     end
  #     
  #     Valued.user_id # => nil
  #
  #   @see Helpers#with
  #   @param data [Hash, nil] The data to apply only to the nested scope.
  #   @yield [Valued::Scope] Yields the scope to the block.
  def self.scope(data = nil, &block)
    raise RuntimeError, "Need to call Valued.connect before Valued.scope" unless defined? @scope and @scope
    return @scope unless data || block
    block ? @scope.scope(data, &block) : @scope.apply(data)
  end

  # @example Called with a data hash
  #   Valued.config({
  #     goals: [
  #       {
  #         name: "This is the name of the goal",
  #         action_key: "Portal.Expense.Created",
  #         min_count: 5
  #       }
  #     ],
  #     signals: [
  #       {
  #         name: "This is the name of the goal",
  #         action_key: "Portal.Expense.Created",
  #         min_count: 5
  #       }
  #     ]
  #   })
  #
  # @example Called with a block
  #   Valued.config do |config|
  #     # Create or update a goal
  #     config.add_goal("This is the name of the goal",
  #       action_key: "Portal.Expense.Created",
  #       min_count: 5)
  #
  #     # Create or update a signal
  #     config.add_signal("This is the name of the signal",
  #       action_key: "Portal.Expense.Created")
  #   end
  #
  # @return [void]
  def config(...) = client.config(...)

  # Resets the shared scope.
  # @see Valued::Scope#reset
  # @return [void]
  def self.reset = scope.reset
end
