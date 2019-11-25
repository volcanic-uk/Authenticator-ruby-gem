# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    module Warden
      # this class create a rack for auth strategy failure
      class AuthFailure
        def call(env)
          @env = env
          [status, headers, [body]]
        end

        # http response
        def status
          401 # Unauthorized
        end

        def headers
          { 'Content-Type' => 'application/json' }
        end

        def body
          { message: @env['warden'].message }.to_json
        end
      end
    end
  end
end
