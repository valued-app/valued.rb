# frozen_string_literal: true

module Valued::Rails
  class ProcessAction
    # Called by ActiveSupport::Notifications when a process_action.action_controller event is published.
    # @api private
    def self.call(name, start, finish, id, payload)
      return unless name == "process_action.action_controller"
      Valued::Rails.process_action(new(start: start, finish: finish, **payload))
    end

    # @return [Time] the time the controller action started
    attr_reader :start

    # @return [Time] the time the controller action finished
    attr_reader :finish

    # @return [String] the controller class name
    attr_reader :controller

    # @return [String] the controller action name
    attr_reader :action

    # @return [Hash] the controller action parameters without any filtered parameter
    attr_reader :params

    # @return [ActionDispatch::Http::Headers] the request headers
    attr_reader :headers

    # @return [Symbol] the response format (:html, :json, :xml, etc.)
    attr_reader :format

    # @return [String] the controller action method ("GET", "POST", etc.)
    attr_reader :method

    # @return [String] the controller action path
    attr_reader :path

    # @return [ActionDispatch::Request] the request object
    attr_reader :request

    # @return [ActionDispatch::Response] the response object
    attr_reader :response

    # @return [Integer] the response status code
    attr_reader :status

    # @api private
    def initialize(start:, finish:, controller:, action:, params:, headers:, format:, method:, path:, request:, response:, status:)
      @start      = start
      @finish     = finish
      @controller = controller
      @action     = action
      @params     = params
      @headers    = headers
      @format     = format
      @method     = method
      @path       = path
      @request    = request
      @response   = response
      @status     = status
    end

    # @return [ActionDispatch::Session::AbstractSecureStore] the session object
    def session = request.session

    # @return [Warden::Proxy, nil] the warden object if Warden/Devise is set up
    def warden = request.env['warden']

    # @return [Object, nil] the current user if Warden/Devise is set up and the user is authenticated
    # @todo Needs to be overridable with custom logic.
    def user = @user ||= find_user

    # @return [true, false] whether {#user} is set
    def user? = !!user

    # @return [Object, nil] Currently active customer if available.
    # @todo Needs to be overridable with custom logic.
    def customer = @customer ||= find_customer
  
    private

    def find_user
      return unless warden
      warden.user(:user) || warden.user
    end
  
    def find_customer
      return ActsAsTenant.current_tenant if defined? ActsAsTenant and ActsAsTenant.current_tenant
      return unless user
      return user.customer     if user.respond_to? :customer
      return user.organization if user.respond_to? :organization
      return user.account      if user.respond_to? :account
    end
  end
end