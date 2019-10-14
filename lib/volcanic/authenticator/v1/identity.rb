# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'
require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Identity API
    class Identity < Common
      include Request
      include Error

      # end-point
      PATH = 'api/v1/identity'
      EXCEPTION = :raise_exception_identity

      attr_accessor :name, :secret
      attr_reader :id, :principal_id, :created_at, :updated_at
      attr_writer :_privileges, :_roles

      def initialize(id:, **opts)
        @id = id
        %i[name principal_id secret created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      def self.path
        PATH
      end

      # updating identity
      # identity.save
      # eg.
      #   identity = Identity.create(...)
      #   identity.name = 'new_name'
      #   identity.save
      #
      # NOTE: Only use for updating identity. Not creating
      def save
        super({ name: name })
      end

      # updating privileges
      # TODO: able to accept objects or ids
      def update_privileges(*ids)
        payload = { privileges: ids.flatten.compact }
        path = [PATH, "/#{id}", '/privileges'].join
        _res = perform_post_and_parse EXCEPTION, path, payload.to_json
        # TODO: return array of Privileges
        # @_privileges = Privilege.new(res)
      end

      # updating roles
      # TODO: able to accept objects or ids
      def update_roles(*ids)
        payload = { roles: ids.flatten.compact }
        path = [PATH, "/#{id}", '/roles'].join
        _res = perform_post_and_parse EXCEPTION, path, payload.to_json
        # TODO: return array of Roles
        # @_roles = Role.new(res)
      end

      def privileges
        @_privileges
      end

      def roles
        @_roles
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
        payload = { secret: new_secret }.to_json
        path = [PATH, '/secret/reset/', id].join
        parsed = perform_post_and_parse EXCEPTION, path, payload
        self.secret = parsed['secret'] || new_secret
      end

      # delete identity
      def delete
        path = [PATH, '/deactivate/', id].join
        perform_post_and_parse EXCEPTION, path
      end

      class << self
        # identity not supporting this method
        undef_method :find
        undef_method :find_by_id

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
        #   privileges = Privileges.find(query: '123@abc.com') # return collection of privileges
        #   roles = Roles.find(query: 'auth_admin') # return collection of roles
        #   Identity.create('name', 1, privileges: privileges roles: roles)
        #
        #   # all options
        #   opts = { secret: 'new_secret', privileges: privileges, roles: roles }
        #   Identity.create('name', 1, opts)
        #
        def create(name, principal_id, secret: nil, skip_encryption: false, privileges: [], roles: [])
          # TODO: raise error if privileges and roles not an objects
          privilege_ids = privileges.collect(&:id)
          role_ids = roles.collect(&:id)
          payload = { name: name,
                      principal_id: principal_id,
                      skip_secret_encryption: skip_encryption,
                      secret: secret,
                      privileges: privilege_ids,
                      roles: role_ids }
          identity = super payload
          identity.secret ||= secret
          identity._privileges = privileges
          identity._roles = roles
          identity
        end

        # updating identity
        # Identity.update(name:, secret:, roles:, privileges:)
        # eg.
        #   updates = { name: 'new_name', secret: 'new_secret', roles: [1], privileges: [1, 3]}
        #   Identity.update(1, updates)
        # def update(id, **payload)
        #   payload.merge!(id: id)
        #   new(payload.transform_keys!(&:to_sym)).save
        # end
        #
        # # reset identity
        # def reset_secret(id, secret = nil)
        #   new(id: id).reset_secret(secret)
        # end
        #
        # # delete identity
        # def delete(id)
        #   new(id: id).delete
        # end

        # similar to update, but ony for privileges update
        #  eg.
        #   Identity.set_privileges(1, 1, 2)
        #   # OR
        #   Identity.set_privileges(1, [1, 2])
        # def W

        # similar to update, but ony for roles update
        #  eg.
        #   Identity.set_roles(1, 1, 2)
        #   # OR
        #   Identity.set_roles(1, [1, 2])
        # def set_roles(id, *roles)
        #   new(id: id, roles: roles.flatten.compact).save_roles
        # end
      end
    end
  end
end
