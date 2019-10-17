# frozen_string_literal: true

require 'jwt'
require_relative 'helper/request'
require_relative 'helper/error'
require_relative 'helper/app_token'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    # Token class
    class Token < Base
      include Error
      include Request

      IDENTITY_PATH = 'api/v1/identity/'
      TOKEN_VALIDATE_PATH = 'api/v1/token/validate'
      EXCEPTION = :raise_exception_token

      attr_accessor :token_key
      attr_reader :kid, :exp, :sub, :nbf, :audience, :iat, :iss, :jti
      attr_reader :stack_id, :dataset_id, :principal_id, :identity_id

      def initialize(token)
        @token_key = token
        fetch_claims
      end

      # to validate token exists at cache or has a valid signature.
      # eg.
      #   Token.new(token_key).validate
      #   # => true/false
      #
      def validate(sign_key = Key.fetch_and_request(kid))
        decode!(sign_key, true) # decode token with verify true
        true
      rescue TokenError
        false
      end

      # to validate token by authenticator service
      #
      # eg.
      #   Token.new(token_key).remote_validate
      #   # => true/false
      #
      def remote_validate
        perform_post_and_parse EXCEPTION, TOKEN_VALIDATE_PATH, nil, token_key
        true
      rescue AuthorizationError
        false
      end

      # to blacklist token (logout)
      # eg.
      #   Token.new(token_key).revoke!
      #
      def revoke!
        path = [IDENTITY_PATH, 'logout'].join
        perform_post_and_parse EXCEPTION, path, nil, token_key
      end

      private

      def decode!(public_key = nil, verify = false)
        JWT.decode token_key, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError, JWT::ImmatureSignature, JWT::ExpiredSignature => e
        raise TokenError, e
      end

      def fetch_claims
        # set all claim as getter
        body, header = decode!
        @kid = header['kid']
        body.each do |k, v|
          instance_variable_set("@#{k}", v)
        end

        # typical subject structure is:
        # "user://{stack_id}/{dataset_id}/{principal_id}/{identity_id}"
        sub_uri = URI(@sub)
        @stack_id = sub_uri.host
        subject = sub_uri.path.split('/').map do |v|
          ['', 'undefined', 'null'].include?(v) ? nil : v
        end
        _, @dataset_id, @principal_id, @identity_id, = subject
      rescue ArgumentError => e
        raise TokenError, e
      end
    end
  end
end
