require 'httparty'
require_relative 'header'
require_relative 'error'
require_relative '../base'

module Volcanic::Authenticator
  module V1
    ##
    # Application token helper.
    # This helper responsible on requesting the application token
    # and cache it at Volcanic::Cache.
    # It request a new token when cache expire.
    class AppToken < Base
      class << self
        include Error
        include Header

        APP_TOKEN = 'volcanic_application_token'

        def fetch_and_request
          cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:request_app_token)
        end

        def request_app_token
          url = [Volcanic::Authenticator.config.auth_url,
                 GENERATE_TOKEN_URL].join('/')
          name =  Volcanic::Authenticator.config.app_name
          secret = Volcanic::Authenticator.config.app_secret
          payload = { name: name, secret: secret }.to_json
          res = HTTParty.post(url, body: payload)
          raise_exception_app_token(res) unless res.success?
          # return token string
          JSON.parse(res.body)['response']['token']
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        end
      end
    end
  end
end