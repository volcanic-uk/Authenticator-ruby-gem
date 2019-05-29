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
      attr_reader :token, :kid, :sub, :iss, :dataset_id, :principal_id, :identity_id

      def initialize(token)
        @token = token
      end

      def caching!
        cache.fetch token, expire_in: exp_token, &method(:token)
      end

      def decode!
        JWT.decode token, TokenKey.fetch_and_request_public_key, true, algorithm: 'ES512'
      rescue JWT::DecodeError
        raise TokenError
      end

      def decode_with_claims!
        fetch_claims(decode!)
      end

      private

      def fetch_claims(dec_token)
        header = dec_token.last
        body = dec_token.first
        @kid = header['kid']
        @sub = body['sub']
        @iss = body['iss']

        sub_uri = URI(@sub)
        _, @dataset_id, @principal_id, @identity_id = sub_uri.path.split('/')
      end
    end
  end
end
