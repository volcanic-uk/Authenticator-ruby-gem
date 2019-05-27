require 'httparty'
require_relative 'header'
require_relative 'error_response'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    ##
    # This class is for requesting and caching application token and public key
    class TokenKey < Base
      extend ErrorResponse
      extend Volcanic::Authenticator::V1::Header

      class << self
        def fetch_and_request_app_token
          cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:request_app_token)
        end

        def fetch_and_request_public_key
          cache.fetch PUBLIC_KEY, expire_in: exp_app_token, &method(:request_public_key)
        end

        def request_app_token
          url = Volcanic::Authenticator.config.auth_url
          payload = { name: Volcanic::Authenticator.config.app_name,
                      secret: Volcanic::Authenticator.config.app_secret }.to_json
          res = HTTParty.post("#{url}/#{IDENTITY_LOGIN}",
                              body: payload)
          raise_exception_if_error res, 'app_token'
          JSON.parse(res.body)['response']['token']
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        end

        def request_public_key
          url = Volcanic::Authenticator.config.auth_url
          res = HTTParty.get("#{url}/#{PUBLIC_KEY_GENERATE}",
                             headers: bearer_header(request_app_token))
          raise_exception_if_error res
          pem = JSON.parse(res.body)['response']['key']
          OpenSSL::PKey.read(pem)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        end
      end
    end
  end
end
