# frozen_string_literal: true

require 'jwt'
require 'digest/md5'
require_relative 'helper/request'
require_relative 'helper/app_token'
require_relative 'privilege'

module Volcanic::Authenticator
  module V1
    # Token
    class Token
      include Request

      TOKEN_PATH = 'api/v1/token/'
      EXCEPTION = TokenError
      CLAIMS = %i[sub exp nbf aud iat iss scope jti].freeze

      attr_accessor :token_base64
      attr_reader(*CLAIMS, :kid, :stack_id, :dataset_id, :principal_id, :identity_id)

      def initialize(token = nil, checksum: nil, **claims)
        @token_base64 = token
        fetch_claims(**claims) unless checksum
        @generate_checksum = checksum
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
        path = [TOKEN_PATH, 'validate'].join
        perform_post_and_parse EXCEPTION, path, nil, token_base64
        true
      rescue AuthorizationError
        false
      end

      # to blacklist token (logout)
      # eg.
      #   Token.new(token_base64).revoke!
      #
      def revoke!
        path = [TOKEN_PATH, generate_checksum].join
        perform_delete_and_parse EXCEPTION, path
      end

      # Used to return privileges for this user
      # for given service or scope.
      #
      # e.g.
      #   Token.new(token_base64).get_permissions_for_service('ats')
      #
      # returns:
      #   Array[Privilege, Privilege]
      def get_privileges_for_service(service)
        (@get_privileges_for_service ||= {})[service] ||=
          if @scope
            self.class.privileges_for(@token_base64, service)
          else
            Subject.privileges_for(@sub, service)
          end
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

      def generate_checksum
        @generate_checksum ||= Digest::MD5.hexdigest(claims_payload.to_json)
      end

      alias checksum generate_checksum

      def self.revoke(checksum)
        new(checksum: checksum).revoke!
      end

      def self.privileges_for(token_base64, service)
        response = perform_get_and_parse(EXCEPTION, "api/v1/privileges/identity?filter[service]=#{service}", token_base64)
        Privilege.parser(response)
      end

      private

      def decode!(public_key = nil, verify = true)
        # public key is required if verify is set to true
        JWT.decode token_base64, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError, JWT::ImmatureSignature, JWT::ExpiredSignature => e
        raise TokenError, e
      end

      def fetch_claims(**claims)
        # set claims as instance variable
        body = claims

        if token_base64
          body, header = decode!(nil, false)
          @kid = header['kid'] if header
        end

        CLAIMS.each do |claim|
          instance_variable_set("@#{claim}", body[claim] || body[claim.to_s])
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

      def claims_payload
        payload = {}
        CLAIMS.each do |claim|
          instance_variable = instance_variable_get("@#{claim}")
          payload[claim] = instance_variable if instance_variable
        end

        payload.sort.to_h
      end
    end
  end
end
