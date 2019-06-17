require 'jwt'
require 'httparty'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    # Token helper
    class Token
      extend Forwardable
      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :key_store_type
      attr_reader :token, :kid, :sub, :iss, :dataset_id, :principal_id, :identity_id

      def initialize(token)
        @token = token
      end

      ##
      # Cache token
      # Eg.
      #  Token.new('TOKEN_KEY').cache!
      #
      def cache!
        cache.fetch token, expire_in: exp_token, &method(:token)
      end

      ##
      # Decode and get claims.
      # Eg.
      #  token.decode_with_claims!
      #  token.kid # => key id claim
      #  token.sub # => subject claim
      #  token.iss # => issuer claim
      #
      #  token.dataset_id # => dataset id from sub
      #  token.principal_id # => principal id from sub
      #  token.identity_id # => identity id from su
      #
      def decode_with_claims!
        fetch_claims(decode!)
      end

      ##
      # Verify token signature.
      # Raise exception (TokenError) for invalid token.
      # Eg.
      #  token.verify!
      #
      def verify!
        ##
        # Decode and get claims. This method is to fetch KID claims
        fetch_claims(decode!)
        # Decode with verify signature
        current_kid = key_store_type == 'static' ? nil : kid
        decode!(TokenKey.fetch_and_request_public_key(current_kid), true)
      end

      private

      def decode!(public_key = nil, verify = false)
        JWT.decode token, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError => e
        raise TokenError, e
      end

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
