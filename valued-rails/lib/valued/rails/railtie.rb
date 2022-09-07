# frozen_string_literal: true

module Valued::Rails
  class Railtie < ::Rails::Railtie
    initializer "valued.initialize" do
      ActiveSupport::Notifications.subscribe "process_action.action_controller", ProcessAction
    end
  end
end