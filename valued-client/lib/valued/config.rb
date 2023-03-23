# frozen_string_literal: true

# Small configuration DSL to create goals and signals.
class Valued::Config
  # @see Client#config
  # @api private
  def initialize(data = nil)
    @data = Data.normalize(data || {})
    @data["signals"] ||= []
    @data["goals"] ||= []
  end

  def add(type, info)
  end

  # @return [Hash] The configuration data as expected by the Valued API.
  def to_h = @data
  alias_method :to_valued_data, :to_h
end