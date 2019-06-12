require 'httparty'
require_relative 'header'
require_relative 'error'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    ##
    # Public key and Application token helper
    class TokenKey < Base
      class << self
        include Error
        include Header

        def fetch_and_request_app_token
          cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:request_app_token)
        end

        def fetch_and_request_public_key(kid = nil)
          cache.fetch kid, expire_in: exp_public_key do
            request_public_key(kid)
          end
        end

        def request_app_token
          url = [Volcanic::Authenticator.config.auth_url, IDENTITY_LOGIN].join('/')
          payload = { name: Volcanic::Authenticator.config.app_name,
                      secret: Volcanic::Authenticator.config.app_secret }.to_json
          res = HTTParty.post(url,
                              body: payload)
          raise_exception_app(res) unless res.success?
          JSON.parse(res.body)['response']['token']
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        end

        def request_public_key(kid)
          url = [Volcanic::Authenticator.config.auth_url, PUBLIC_KEY_GENERATE, kid].join('/')
          res = HTTParty.get("#{url}?expired=true",
                             headers: bearer_header(request_app_token))
          raise_exception_standard res unless res.success?
          pem = JSON.parse(res.body)['response']['key']['public_key']
          OpenSSL::PKey.read(pem)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        rescue OpenSSL::PKey::PKeyError => e
          raise KeyError, e
        end
      end
    end
  end
end
