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
          token = cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:request_app_token)
          parsed_token = Volcanic::Authenticator::V1::Token.new(token)

          cache.update_ttl_for(APP_TOKEN, expire_at: [Time.now.to_i + exp_app_token, parsed_token.exp].min - 1) do |cached_token|
            cached_token == token
          end

          token
        end

        def request_app_token
          payload = { name: app_name,
                      secret: app_secret,
                      dataset_id: app_dataset_id,
                      audience: ['*'] }.to_json # TODO: audience should be set of to what/who the direction is. eg 'vault'
          perform_post_and_parse(EXCEPTION, GENERATE_TOKEN_URL, payload, nil)['token']
        end

        def invalidate_cache!
          cache.evict!(APP_TOKEN)
        end
      end
    end
  end
end
