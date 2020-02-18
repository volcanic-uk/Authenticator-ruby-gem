# frozen_string_literal: true

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
        include Request

        APP_TOKEN = 'volcanic_application_token'
        # Token end-point
        GENERATE_TOKEN_URL = 'api/v1/identity/login'
        EXCEPTION = ApplicationTokenError

        def fetch_and_request
          cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:request_app_token)
        end

        def request_app_token
          payload = { name: app_name,
                      secret: app_secret,
                      dataset_id: app_dataset_id,
                      audience: ['*'] }.to_json # TODO: audience should be set of to what/who the direction is. eg 'vault'
          perform_post_and_parse(EXCEPTION, GENERATE_TOKEN_URL, payload, nil)['token']
        end
      end
    end
  end
end
