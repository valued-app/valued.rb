# frozen_string_literal: true

module Valued::Rails
  class Middleware
    def initialize(app) = @app = app
    
    def call(env)
      return @app.call(env)  unless client = Setup.client
      Valued.connect(client) unless Valued.connected? and Valued.client == client
      Valued.scope do |scope|
        env["valued.client"] = client
        env["valued.scope"]  = scope
        @app.call(env)
      end
    end
  end
end