# frozen_string_literal: true

require_relative '../base'
require_relative 'app_token'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    ##
    # Public key and Application token helper
    class Key < Base
      class << self
        include Request

        PUBLIC_KEY = 'volcanic_public_key'
        # Public Key end-point
        PUBLIC_KEY_URL = 'api/v1/key'
        EXCEPTION = :raise_exception_app_token

        def fetch_and_request(kid)
          cache.fetch kid, expire_in: exp_public_key do
            request_public_key(kid)
          end
        end

        def request_public_key(kid)
          url = [PUBLIC_KEY_URL, kid].join('/')
          auth_token = AppToken.request_app_token
          parsed = perform_get_and_parse EXCEPTION, "#{url}?expired=true", auth_token
          OpenSSL::PKey.read(parsed['public_key'])
        rescue OpenSSL::PKey::PKeyError => e
          raise SignatureError, e
        end
      end
    end
  end
end
