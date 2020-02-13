# frozen_string_literal: true

module Volcanic::Authenticator
  module Warden
    # AuthFailure is not automatically apply to the application after installing the gem. This need be done manually
    # We can configure AuthFailure at config/application.rb as:
    #
    #   config.middleware.use Warden::Manager do |manager|
    #     manager.failure_app = Volcanic::Authenticator::Warden::AuthFailure
    #   end
    #
    # By default AuthFailure returning rack response of
    #   [401, { 'Context-Type' => 'application/json' }, ["{\"message\":\"Authorization header is invalid!\"}"] ]
    #
    # To enable redirecting, provide the +redirect+ opts and set to true when initialize the scope. By default +redirect+ is set to false
    # eg.
    #   Warden::Manger.default_scope(:label_scope, strategies: [...], redirect_on_fail: '/')
    #   # this will redirect the request when failure happened. By default it redirect to '/'
    #
    # The redirect path can be change by providing the +action+ value
    # eg.
    #   # when authenticating
    #   request.env['warden'].authenticate!(:auth_token, redirect_on_fail: new_login_path)
    #
    #   # when scoping
    #   Warden::Manger.default_scope(:label_scope, strategies: [...], redirect_on_fail: '/login/new')
    #
    # The rack response can be customize. Provide the +opts+ when defining +failure_app+
    # eg.
    #   opts = { status: 401, headers: { 'Content-Type' => 'application/json' }, body: { message: 'Authorization header is invalid!' } }
    #   manager.failure_app = Volcanic::Authenticator::Warden::AuthFailure.new(opts)
    #
    class AuthFailure
      attr_accessor :env

      def self.call(env)
        new.call(env)
      end

      def initialize(status: nil, headers: {}, body: nil)
        @status = status
        @headers = headers
        @body = body
      end

      def call(env)
        @env = env
        [status, headers, [body&.to_json]]
      end

      private

      def status
        @status ||= redirect? ? 302 : 401
      end

      def headers
        process_headers(@headers)
      end

      def body
        @body ||= error_message
      end

      def process_headers(custom_headers)
        headers = redirect? ? { 'location' => redirect_url } : { 'Context-Type' => 'application/json' }
        headers.merge!(custom_headers || {})
      end

      def error_message
        { message: env && env['warden']&.message || 'unauthorized!' } unless redirect?
      end

      def redirect_url
        env && env['warden.options'] && env['warden.options'][:redirect_on_fail]
      end

      # alias to be more readable
      alias redirect? redirect_url
    end
  end
end
