# frozen_string_literal: true

module Valued::Rails
  class Railtie < ::Rails::Railtie
    initializer "valued.initialize" do |app|
      ActiveSupport::Notifications.subscribe "process_action.action_controller", ProcessAction
      app.middleware.use Middleware
    end
  end
end