# frozen_string_literal: true

module Valued::Rails::Setup
  class Main
    # @return [Valued::Rails::Setup::Connection]
    def connection(*conditions)
      return unless check_conditions(conditions)
      @connection ||= Connection.new
    end

    private

    def check_conditions(condition)
     case condition
     when true, false then condition
     when Proc        then check_conditions(condition.call)
     when Symbol      then check_conditions(condition.name)
     when String      then Rails.env == condition
     when Array       then condition.empty? or condition.any? { check_conditions(_1) }
     else raise ArgumentError, "Unknown condition: #{condition.inspect}"
     end
    end
  end
end