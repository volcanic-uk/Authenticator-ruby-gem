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
      include Error
      include Request
      extend Error
      extend Request

      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :auth_url

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
      # return string token key
      #
      # eg.
      #   Token.create(name, secret)
      #   # => 'eyJhbGciOiJFUzUxMiIsIn...'
      #
      def self.create(name, secret)
        payload = { name: name, secret: secret }.to_json
        perform_post_and_parse(TOKEN_EXCEPTION,
                               GENERATE_TOKEN_URL,
                               payload, nil)['token']
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
        return true if cache.key?(token_key)

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
      def remote_validate
        return true if cache.key?(token_key)

        res = HTTParty.post("#{auth_url}/#{VALIDATE_TOKEN_URL}",
                            headers: bearer_header(token_key))
        cache! if res.success?
        # Logger.new(STDOUT).error(JSON.parse(res.body)['message']) unless res.success?
        res.success?
      end

      #
      # fetching claims.
      #
      # eg.
      #  token = Token.new(token_key).fetch_claims
      #  token.kid # => key id
      #  token.sub # => subject
      #  token.iss # => issuer
      #  token.dataset_id # => dataset id
      #  token.principal_id # => principal id
      #  token.identity_id # => identity id
      #
      def fetch_claims
        claims_extractor
        self
      end

      #
      # to clear token at cache
      # eg.
      #   Token.new(token_key).destroy
      def clear!
        cache.evict!(token_key) unless token_key.nil?
      end

      #
      # to blacklist token and delete at cache
      # eg.
      #   Token.new(token_key).revoke!
      #
      def revoke!
        clear!
        perform_post_and_parse TOKEN_EXCEPTION, REVOKE_TOKEN_URL, nil, token_key
      end

      private

      def cache!
        cache.fetch token_key, expire_in: exp_token, &method(:token_key)
      end

      def verify_signature
        claims_extractor # to fetch KID from token
        decode!(Key.fetch_and_request(kid), true) # decode token with verify true
      end

      def decode!(public_key = nil, verify = false)
        JWT.decode token_key, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError => e
        raise TokenError, e
      end

      def claims_extractor
        decoded_token = decode!
        header = decoded_token.last
        body = decoded_token.first
        @kid = header['kid']
        @sub = body['sub']
        @iss = body['iss']

        sub_uri = URI(@sub)
        _, @dataset_id, @principal_id, @identity_id = sub_uri.path.split('/')
      end
    end
  end
end
