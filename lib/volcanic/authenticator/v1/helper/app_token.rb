# frozen_string_literal: true

require_relative '../base'
require_relative 'request'
require_relative '../token'

module Volcanic::Authenticator
  module V1
    # Application token helper.
    # This helper responsible on requesting the application token
    # and cache it at Volcanic::Cache.
    # It request a new token when cache expire.
    class AppToken < Base
      class << self
        include Request

        KEY = 'volcanic_application_token' # constant key name
        PATH = 'api/v1/identity/login'
        EXCEPTION = :raise_exception_app_token

        # fetch token from cache memory
        def fetch_and_request
          token = Token.new(fetch_token)
          # updating cache ttl to follow token expiry time
          update_cache_ttl(token)
          token.token_base64
        end

        # fetch token from requesting to AUTH Service
        def request_new
          payload = { name: app_name, secret: app_secret,
                      dataset_id: app_dataset_id, audience: ['*'] }.to_json # TODO: audience should be set of to what/who the direction is. eg 'vault'
          perform_post_and_parse(EXCEPTION, PATH, payload, nil)['token']
        end

        private

        def fetch_token
          cache.fetch KEY, expire_in: exp_app_token, &method(:request_new)
        end

        def update_cache_ttl(token)
          # only update if ttl is different with token.exp
          cache.update_ttl_for KEY, expire_at: token.exp unless cache.ttl_for(KEY) == token.exp
        end
      end
    end
  end
end
