# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    #
    # Handle identity api
    # method => :register, :deactivate
    # attr => :name, :secret, :id, :principal_id, :token
    class Identity < Base
      include Request
      include Error

      # end-point
      IDENTITY_CREATE_URL = 'api/v1/identity'
      TOKEN_CREATE_URL = 'api/v1/identity/login'
      IDENTITY_DELETE_URL = 'api/v1/identity/deactivate'
      EXCEPTION = :raise_exception_identity

      attr_reader :id, :name, :secret, :principal_id

      def initialize(id: nil, name: nil, secret: nil, principal_id: nil, **_opts)
        @id = id
        @name = name
        @principal_id = principal_id
        @secret = secret
      end

      #
      # to generate new token.
      # this is similar to
      #   Token.create(name, secret).token
      #
      # eg.
      #  token = Identity.new(name, secret).token
      #  # => return a token
      #
      def token
        # Token.create(@name, @secret).token
        payload = { name: name, secret: secret }.to_json
        perform_post_and_parse(EXCEPTION, TOKEN_CREATE_URL, payload)['token']
      end

      ##
      # Deactivate an identity and blacklist all associate tokens.
      # Eg.
      #   Identity.delete(identity_id)
      #
      def delete
        perform_post_and_parse EXCEPTION, "#{IDENTITY_DELETE_URL}/#{id}"
      end

      class << self
        include Request
        include Error
        #
        # Create identity
        # eg.
        #   identity = Identity.register(name, secret, principal_id)
        #
        def create(name, principal_id, secret = nil, privileges = [], roles = [])
          payload = { name: name,
                      principal_id: principal_id,
                      secret: secret,
                      privileges: privileges,
                      roles: roles }.to_json
          parsed = perform_post_and_parse EXCEPTION, IDENTITY_CREATE_URL, payload
          parsed['secret'] = secret if parsed['secret'].nil?
          new(parsed.transform_keys!(&:to_sym))
        end
      end
    end
  end
end
