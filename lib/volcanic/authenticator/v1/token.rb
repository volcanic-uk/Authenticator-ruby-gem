# frozen_string_literal: true

require 'jwt'
require_relative 'helper/request'
require_relative 'helper/app_token'

module Volcanic::Authenticator
  module V1
    # Token
    class Token
      include Request

      IDENTITY_PATH = 'api/v1/identity/'
      TOKEN_VALIDATE_PATH = 'api/v1/token/validate'
      EXCEPTION = TokenError
      CLAIMS = %i[sub exp nbf audience iat iss jti].freeze

      attr_accessor :token_base64
      attr_reader(*CLAIMS)
      attr_reader :kid, :stack_id, :dataset_id, :principal_id, :identity_id

      def initialize(token)
        @token_base64 = token
        fetch_claims
      end

      # to validate token exists at cache or has a valid signature.
      # eg.
      #   Token.new(token_base64).validate
      #   # => true/false
      #
      def validate
        # fetch a signature/public key that use for decoding token
        decode! Key.fetch_and_request(kid)
        true
      rescue TokenError
        false
      end

      # to validate token by authenticator service
      #
      # eg.
      #   Token.new(token_base64).remote_validate
      #   # => true/false
      #
      def remote_validate
        perform_post_and_parse EXCEPTION, TOKEN_VALIDATE_PATH, nil, token_base64
        true
      rescue AuthorizationError
        false
      end

      # to blacklist token (logout)
      # eg.
      #   Token.new(token_base64).revoke!
      #
      def revoke!
        path = [IDENTITY_PATH, 'logout'].join
        perform_post_and_parse EXCEPTION, path, nil, token_base64
      end

      # Used to return privileges for this user
      # for given service.
      #
      # e.g.
      #   Token.new(token_base64).get_permissions_for_service('ats')
      #
      # returns:
      #   Array[Privilege, Privilege]
      def get_privileges_for_service(service)
        (@get_privileges_for_service ||= {})[service] ||= Subject.privileges_for(@sub, service)
      end

      def identity
        return nil if identity_id.nil?

        Identity.new(id: identity_id, dataset_id: dataset_id, principal_id: principal_id, stack_id: stack_id)
      end

      def principal
        return nil if principal_id.nil?

        Principal.new(dataset_id: dataset_id, id: principal_id, stack_id: stack_id)
      end

      def subject
        identity || principal
      end

      private

      def decode!(public_key = nil, verify = true)
        # public key is required if verify is set to true
        JWT.decode token_base64, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError, JWT::ImmatureSignature, JWT::ExpiredSignature => e
        raise TokenError, e
      end

      def fetch_claims
        # set claims as instance variable
        body, header = decode! nil, false
        @kid = header['kid']
        CLAIMS.each do |claim|
          instance_variable_set("@#{claim}", body[claim.to_s])
        end
        extract_subject
      end

      def extract_subject
        # subject: "user://{stack_id}/{dataset_id}/{principal_id}/{identity_id}"
        sub_uri = URI(@sub)
        @stack_id = sub_uri.host
        subject = sub_uri.path.split('/').map do |v|
          ['', 'undefined', 'null'].include?(v) ? nil : v
        end
        # set these as instance variable
        _, @dataset_id, @principal_id, @identity_id, = subject
      rescue ArgumentError => e
        raise TokenError, e
      end
    end
  end
end
