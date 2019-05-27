require 'jwt'
require 'httparty'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    # Helper for Token handling
    class Token
      extend Forwardable
      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegator 'Volcanic::Authenticator.config'.to_sym, :exp_token
      attr_reader :token

      def initialize(token)
        @token = token
      end

      def caching!
        cache.fetch token, expire_in: exp_token, &method(:token)
      end

      def valid?
        JWT.decode token, TokenKey.fetch_and_request_public_key, true, algorithm: 'ES512'
      rescue JWT::DecodeError
        raise TokenError
      end
    end
  end
end
