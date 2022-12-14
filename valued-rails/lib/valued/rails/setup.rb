# frozen_string_literal: true

module Valued::Rails::Setup
  # @!attribute [r] main
  # @return [Main] The main setup object.
  # @api private
  def self.main = @main ||= Main.new

  # Executes the given block via the {DSL} wrapper.
  # @see Valued::Rails.setup
  # @return [Main] The main setup object.
  def self.run(&block)
    Valued::Rails::DSL.run(main, block)
    connect
    main
  end

  # @return [true, false]
  # @api private
  def self.connect
    Valued.connect(main.connection.client) if main.connection.client?
    Valued.connected?
  end

  # @return [Valued::Client, nil]
  # @api private
  def self.client = main.connection.client
end