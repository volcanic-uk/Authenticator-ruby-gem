# frozen_string_literal: true

require 'jwt'
require 'logger'
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

      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :key_store_type

      VALIDATE_TOKEN_URL = 'api/v1/token/validate'
      GENERATE_TOKEN_URL = 'api/v1/identity/login'
      REVOKE_TOKEN_URL = 'api/v1/identity/logout'
      TOKEN_EXCEPTION = :raise_exception_token

      attr_accessor :token_key
      attr_reader :kid, :sub, :iss, :dataset_id, :principal_id, :identity_id

      def initialize(token_key = nil)
        @token_key = token_key
      end

      #
      # to generate/request token key
      # eg.
      #   token = Token.new.gen_token_key(name, secret)
      #   token.token_key # => 'eyJhbGciOiJFUzUxMiIsIn...'
      #   ....
      #
      def gen_token_key(identity_name, identity_secret)
        payload = { name: identity_name, secret: identity_secret }.to_json
        parsed = perform_post_and_parse TOKEN_EXCEPTION, GENERATE_TOKEN_URL, payload, nil
        @token_key = parsed['token']
        cache!
        self
      end

      #
      # to validate token exists at cache or has a valid signature.
      # eg.
      #   Token.new(token_key).validate
      #   # => true/false
      #
      def validate
        return true if cache.key?(@token_key)

        verify_signature # verify signature
        cache! # if success verify it cache the token again
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
        url = "#{Volcanic::Authenticator.config.auth_url}/#{VALIDATE_TOKEN_URL}"
        res = HTTParty.post(url, headers: bearer_header(token_key))
        unless res.success?
          logger = Logger.new(STDOUT)
          logger.error JSON.parse(res.body)['message']
        end
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
      #  token.identity_id # => identity id from su
      #
      def decode_and_fetch_claims
        fetch_claims
        self
      end

      #
      # to remove/revoke token from cache,
      # then blacklist the token at auth service.
      # eg.
      #   Token.new(token_key).revoke!
      #
      def revoke!
        cache.evict!(token_key) unless token_key.nil?
        perform_post_and_parse TOKEN_EXCEPTION, REVOKE_TOKEN_URL, nil, token_key
      end

      private

      #
      # to cache token
      # Eg.
      #  Token.new(token).cache!
      #
      def cache!
        cache.fetch token_key, expire_in: exp_token, &method(:token_key)
      end

      def verify_signature
        # fetch claims to obtain KID
        fetch_claims
        # Decode with verify signature
        # current_kid = key_store_type == 'static' ? nil : kid
        decode!(Key.fetch_and_request(kid), true)
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
