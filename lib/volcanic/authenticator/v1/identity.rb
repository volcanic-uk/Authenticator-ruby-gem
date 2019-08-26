# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    # Identity API
    class Identity
      include Request
      include Error

      # end-point
      URL = 'api/v1/identity'
      IDENTITY_DELETE_URL = 'api/v1/identity/deactivate'
      RESET_SECRET_URL = 'api/v1/identity/secret/reset/'
      EXCEPTION = :raise_exception_identity

      attr_accessor :name, :secret, :privileges, :roles
      attr_reader :id, :principal_id, :created_at, :updated_at

      def initialize(id:, **opts)
        @id = id
        @name = opts[:name]
        @principal_id = opts[:principal_id]
        @secret = opts[:secret]
        @privileges = opts[:privileges]
        @roles = opts[:roles]
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
      def token
        # Token.create(name, secret, principal_id).token_key
      end

      # Deactivate an identity and blacklist all associate tokens.
      # Eg.
      #   Identity.delete(identity_id)
      #
      def delete
        perform_post_and_parse EXCEPTION, "#{IDENTITY_DELETE_URL}/#{id}"
      end

      # updating identity
      # identity.save
      # eg.
      #   identity = Identity.create(...)
      #   identity.name = 'new_name'
      #   identity.secret = 'new_secret'
      #   identity.save
      #
      # NOTE: Only use for updating identity. Not creating
      def save
        payload = { name: name, secret: secret, privileges: privileges, roles: roles }
        payload.delete_if { |_, value| value.nil? }
        perform_post_and_parse EXCEPTION, "#{URL}/#{id}", payload.to_json
      end

      # reset secret
      # identity.reset_secret
      # eg.
      #   identity.reset_secret
      #   identity.secret #=> 'new_random_secret'
      #   # OR
      #   identity.reset_secret('new_secret')
      #   identity.secret #=> 'new_secret'
      #
      # return the new secret
      def reset_secret(new_secret = nil)
        payload = new_secret.nil? ? {} : { secret: new_secret }
        parsed = perform_post_and_parse EXCEPTION, [RESET_SECRET_URL, id].join, payload.to_json
        @secret = new_secret.nil? ? parsed['secret'] : new_secret
      end

      class << self
        include Request
        include Error
        # Create identity
        # Identity.create(name, principal_id, secret: nil, privileges: [], roles: [])
        # eg.
        #   # with random secret
        #   Identity.create('name', 1)
        #
        #   # with custom secret
        #   Identity.create('name,' 1, secret: 'secret')
        #
        #   # assign roles or privileges
        #   Identity.create('name', 1, privileges: [1, 3] roles: [1])
        #
        #   # all options
        #   opts = { secret: 'new_secret', privileges: [1, 3], roles: [1] }
        #   Identity.create('name', 1, opts)
        #
        def create(name, principal_id, secret: nil, privileges: [], roles: [])
          payload = { name: name,
                      principal_id: principal_id,
                      secret: secret,
                      privileges: privileges,
                      roles: roles }.to_json
          parsed = perform_post_and_parse EXCEPTION, URL, payload
          parsed['secret'] = secret if parsed['secret'].nil?
          parsed.merge!(privileges: privileges, roles: roles)
          new(parsed.transform_keys!(&:to_sym))
        end

        # updating identity
        # Identity.update(name:, secret:, roles:, privileges:)
        # eg.
        #   updates = { name: 'new_name', secret: 'new_secret', roles: [1], privileges: [1, 3]}
        #   Identity.update(1, updates)
        def update(id, **payload)
          payload.merge!(id: id)
          new(payload.transform_keys!(&:to_sym)).save
        end

        # reset identity
        def reset_secret(id, secret = nil)
          new(id: id).reset_secret(secret)
        end

        # delete identity
        def delete(id)
          new(id: id).delete
        end

        # similar to update, but ony for privileges update
        #  eg.
        #   Identity.set_privileges(1, 1, 2)
        #   # OR
        #   Identity.set_privileges(1, [1, 2])
        def set_privileges(id, *privileges)
          new(id: id, privileges: privileges.flatten.compact).save
        end

        # similar to update, but ony for roles update
        #  eg.
        #   Identity.set_roles(1, 1, 2)
        #   # OR
        #   Identity.set_roles(1, [1, 2])
        def set_roles(id, *roles)
          new(id: id, roles: roles.flatten.compact).save
        end
      end
    end
  end
end
