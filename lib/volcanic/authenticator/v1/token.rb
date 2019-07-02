# frozen_string_literal: true

require 'jwt'
require 'httparty'
require_relative 'helper/request'
require_relative 'helper/error'

module Volcanic::Authenticator
  module V1
    # Token class
    # method => :validate, :validate_by_service, :decode_and_fetch_claims, :cache! :revoke!
    # attr => :token, :kid, :sub, :iss, :dataset_id, :principal_id, :identity_id
    class Token
      extend Forwardable
      include Request
      include Error

      VALIDATE_TOKEN_URL = 'api/v1/identity/validate'
      GENERATE_TOKEN_URL = 'api/v1/identity/login'
      REVOKE_TOKEN_URL = 'api/v1/identity/logout'

      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :key_store_type
      attr_reader :token_key, :kid, :sub, :iss, :dataset_id, :principal_id, :identity_id

      def initialize(token_key)
        @token_key = token_key
      end

      #
      # to validate token exists at cache or has a valid signature.
      # if token exist at cache it returns true.
      # if token has a valid signature it return true.
      # eg.
      #   Token.new(token_key).validate
      #   # => true/false
      #
      def validate
        return true if cache.key?(token_key)

        verify_signature
        cache! # if verify_signature do not raise TokenError it cache the token again
        true
      rescue TokenError
        false
      end

      #
      # to validate token by authenticator service
      #
      # eg.
      #   Token.new(token_key).validate_by_service
      #   # => true/false
      #
      def validate_by_service
        payload = { token: token_key }.to_json
        res = perform_post_request(VALIDATE_TOKEN_URL, payload, nil)
        res.success?
      end

      #
      # to decode and fetch claims.
      #
      # eg.
      #  token = Token.new(token_key).decode_and_fetch_claims
      #  token.kid # => key id claim
      #  token.sub # => subject claim
      #  token.iss # => issuer claim
      #
      #  token.dataset_id # => dataset id from sub
      #  token.principal_id # => principal id from sub
      #  token.identity_id # => identity id from sub
      #
      def decode_and_fetch_claims
        fetch_claims
        self
      end

      def cache!
        cache.fetch token_key, expire_in: exp_token, &method(:token_key)
      end

      #
      # to remove/revoke token from cache,
      # then blacklist the token at auth service.
      # eg.
      #   Token.new(token_key).revoke!
      #
      def revoke!
        cache.evict! token_key
        res = perform_post_request(REVOKE_TOKEN_URL, nil, token_key)
        raise_exception_identity(res) unless res.success?
      end

      #
      # to request/generate a new token key
      #
      # eg.
      #   token = Token.create(name, secret)
      #   token.token_key #=> <GENERATED_TOKEN>
      #   ...
      #
      class << self
        include Request
        include Error
        def create(name, secret)
          payload = { name: name, secret: secret }.to_json
          res = perform_post_request(GENERATE_TOKEN_URL, payload, nil)
          raise_exception_identity(res) unless res.success?
          token = new(JSON.parse(res.body)['response']['token'])
          token.cache!
          token
        end
      end

      private

      def verify_signature
        # fetch claims to obtain KID
        fetch_claims
        # Decode with verify signature
        current_kid = key_store_type == 'static' ? nil : kid
        decode!(Key.fetch_and_request(current_kid), true)
      end

      def decode!(public_key = nil, verify = false)
        JWT.decode token_key, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError => e
        raise TokenError, e
      end

      def fetch_claims
        dec_token = decode!
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
