# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    # Handle identity api
    class Identity
      include Request
      include Error

      # end-point
      URL = 'api/v1/identity'
      IDENTITY_DELETE_URL = 'api/v1/identity/deactivate'
      RESET_SECRET_URL = 'api/v1/identity/secret/reset'
      EXCEPTION = :raise_exception_identity

      attr_accessor :name, :secret
      attr_reader :id, :principal_id, :created_at, :updated_at

      def initialize(id:, name: nil, secret: nil, principal_id: nil, **opts)
        @id = id
        @name = name
        @principal_id = principal_id
        @secret = secret
        @created_at = opts[:created_at]
        @updated_at = opts[:updated_at]
      end

      # to generate new token.
      # this is similar to
      #   Token.create(name, secret).token
      #
      # eg.
      #  token = Identity.new(name, secret).token
      #  # => return a token
      #
      # def token
      #   # Token.create(name, secret)
      # end

      # Deactivate an identity and blacklist all associate tokens.
      # Eg.
      #   Identity.delete(identity_id)
      #
      def delete
        perform_post_and_parse EXCEPTION, "#{IDENTITY_DELETE_URL}/#{id}"
      end

      # updating identity
      # eg.
      #   identity = Identity.create(...)
      #   identity.name = 'new_name'
      #   identity.secret = 'new_secret'
      #   identity.save
      #
      # NOTE: Only use for updating identity. Not creating
      def save
        payload = { name: name, secret: secret }.delete_if { |_, value| value.nil? }
        perform_post_and_parse EXCEPTION, "#{URL}/#{id}", payload.to_json
      end

      def reset_secret(new_secret = nil)
        payload = { secret: new_secret }.delete_if { |_, value| value.nil? }
        parsed = perform_post_and_parse EXCEPTION, "#{RESET_SECRET_URL}/#{id}", payload.to_json
        @secret = new_secret.nil? ? parsed['secret'] : new_secret
      end

      class << self
        include Request
        include Error
        # Create identity
        # eg.
        #   name = 'volcanic'
        #   secret = 'volcanic123'
        #   principal_id = 1
        #   privilege_ids = [1, 2]
        #   role_ids = [3, 4]
        #   identity = Identity.create(name, principal_id, secret: secret, principal_id)
        #
        def create(name, principal_id, secret: nil, privileges: [], roles: [])
          payload = { name: name,
                      principal_id: principal_id,
                      secret: secret,
                      privileges: privileges,
                      roles: roles }.to_json
          parsed = perform_post_and_parse EXCEPTION, URL, payload
          parsed['secret'] = secret if parsed['secret'].nil?
          new(parsed.transform_keys!(&:to_sym))
        end

        # updating identity
        # eg.
        #   Identity.update(1, name: 'new_name', secret: 'new_secret')
        #
        def update(id, name: nil, secret: nil)
          payload = { name: name, secret: secret }.delete_if { |_, v| v.nil? }
          perform_post_and_parse EXCEPTION, "#{URL}/#{id}", payload.to_json
        end
      end
    end
  end
end
