# frozen_string_literal: true

require 'httparty'
require 'forwardable'
require 'down'
require_relative 'helper/app_token'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    # This class include HTTParty module and automatically generate
    # authorization header to +headers+.
    #
    # To disable of the authorization header, add to configuration as:
    #
    #   Volcanic::Authorization.config.auth_enabled = false
    #
    # example:
    #
    #   HTTPRequest.get('/api/v1/user', body: {id: '1'}.to_json, headers: {'Content-Type' => '...'})
    #
    #   extending the class:
    #
    #   VaultRequest < HTTPRequest
    #     base_uri 'http://vault.cloud/'
    #   end
    #
    #   VaultRequest.get('api/v1/user')
    #
    # This class also include +download+ method on Down gem.
    # example:
    #
    #   HTTPRequest.download('/api/v1/image').read
    #
    #   # use default base_uri
    #   KrakatoaRequest < HTTPRequest
    #     base_uri 'http://krakatoa.cloud/'
    #   end
    #
    #   KrakatoaRequest.download('/api/v1/image').read
    #
    # NOTE: only support +download+ for now.
    #
    class HTTPRequest < Base
      include HTTParty
      class << self
        # extend this class to have +download+ method from Down gem.
        # +base_uri+ and +headers+ is coming from HTTParty module class methods.
        def download(endpoint, **opts)
          path = [base_uri, endpoint].join
          opts[:headers] = headers
          Down.download(path, opts)
        end

        # Override HTTParty +headers+ method to enable dynamic
        # authorization header.
        def headers(headers = {})
          base_headers = auth_enabled? ? { 'Authorization' => auth_token } : {}
          super base_headers.merge(headers)
        end

        private

        def auth_token
          "Bearer #{AppToken.fetch_and_request}"
        end
      end
    end
  end
end
