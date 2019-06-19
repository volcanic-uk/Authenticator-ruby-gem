# frozen_string_literal: true

require 'httparty'
require_relative 'header'
require_relative 'error'
require_relative '../base'
require_relative 'app_token'

module Volcanic::Authenticator
  module V1
    ##
    # Public key and Application token helper
    class Key < Base
      class << self
        include Error
        include Header

        PUBLIC_KEY = 'volcanic_public_key'

        def fetch_and_request(kid = nil)
          if kid.nil?
            # only for development purpose.
            # Generally kid should not be nil.
            # This method occurs when using static key store type.
            cache.fetch PUBLIC_KEY, expire_in: exp_app_token, &method(:request_public_key)
          else
            cache.fetch kid, expire_in: exp_public_key do
              request_public_key(kid)
            end
          end
        end

        def request_public_key(kid = nil)
          url = [Volcanic::Authenticator.config.auth_url,
                 PUBLIC_KEY_URL, kid].join('/')

          # request an Application token for authorization header
          header = bearer_header(AppToken.request_app_token)
          res = HTTParty.get("#{url}?expired=true", headers: header)
          raise_exception_standard res unless res.success?

          # the response for static and dynamic end-point is different.
          pem = kid.nil? ? JSON.parse(res.body)['response']['key'] : JSON.parse(res.body)['response']['key']['public_key']
          OpenSSL::PKey.read(pem)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        rescue OpenSSL::PKey::PKeyError => e
          raise SignatureError, e
        end
      end
    end
  end
end
