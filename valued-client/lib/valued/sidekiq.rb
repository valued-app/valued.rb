# frozen_string_literal: true

require "valued"
require "sidekiq"

module Valued::Sidekiq
  include Sidekiq::Job

  def perform(data, token = nil, endpoint = nil)
    if token
      endpoint ||= Valued::Connection::DEFAULT_ENDPOINT
      Valued::Connection.new(token, endpoint).call(data)
    else
      Valued.client.connection.call(data)
    end
  end
end