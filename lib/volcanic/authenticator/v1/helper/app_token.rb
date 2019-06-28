# frozen_string_literal: true

require_relative 'header'
require_relative 'error'
require_relative '../base'
require_relative 'request'

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
        include Request

        APP_TOKEN = 'volcanic_application_token'
        # Token end-point
        GENERATE_TOKEN_URL = 'api/v1/identity/login'
        EXCEPTION = :raise_exception_app_token

        def fetch_and_request
          cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:request_app_token)
        end

        def request_app_token
          name = Volcanic::Authenticator.config.app_name
          secret = Volcanic::Authenticator.config.app_secret
          payload = { name: name, secret: secret }.to_json
          perform_post_and_parse(EXCEPTION, GENERATE_TOKEN_URL, payload, nil)['token']
        end
      end
    end
  end
end
