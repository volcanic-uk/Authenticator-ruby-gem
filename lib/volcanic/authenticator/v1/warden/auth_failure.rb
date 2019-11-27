# frozen_string_literal: true

module Volcanic::Authenticator
  module V1::Warden
    # this class create a rack for auth strategy failure
    # this can be modify base it needs.
    class AuthFailure

      attr_accessor :status, :headers, :body

      def initialize(status = nil, headers = nil, body = nil)
        @status = status || 401
        @headers = headers || { 'Content-Type' => 'application/json' }
        @body = body
      end

      def call(env)
        @env = env
        [status, headers, [error_message]]
      end

      def error_message
        body || { message: @env['warden'].message }.to_json
      end
    end
  end
end
