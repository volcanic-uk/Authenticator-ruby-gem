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

      EXCEPTION = :raise_exception_identity

      attr_accessor :name, :secret, :privilege_ids, :role_ids
      attr_reader :id, :principal_id, :created_at, :updated_at

      # identity base path
      def self.path
        'api/v1/identity'
      end

      def initialize(**opts)
        %i[id name principal_id secret created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
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
        super name: name
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
        parsed = perform_post_and_parse EXCEPTION, path('/secret/reset/', id), payload
        self.secret = parsed['secret'] || new_secret
      end

      # TODO: need to remove this when auth service is fixed
      # delete identity
      def delete
        perform_post_and_parse EXCEPTION, path('/deactivate/', id)
      end

      # login. retrieve token when credential is provided
      #
      # eg.
      #   Identity.new(name: 'abc@123.com', secret: 'abc123', principal_id: 1).login
      #   or
      #   opts = { name: 'abc@123.com', secret: 'abc123' }
      #   Identity.new(opts).login('service-a', 'abc123')
      #   # => return token string
      #
      def login(*audience)
        payload = { name: name,
                    secret: secret,
                    principal_id: principal_id,
                    audience: audience.flatten.compact }
        perform_post_and_parse(EXCEPTION, path('/login'),
                               payload.to_json, nil)['token']
      end

      # token. retrieve token when credential is not provided
      #
      # Options:
      #   +audience+: A set of information to tell who/what the token use for. It is a set
      #   strings array
      #   +exp+: A token expiry time. only accept unix timestamp in milliseconds format.
      #   eg: 1571296171000
      #   +nbf+: A token not before time. token will be invalid until it reach nbf time.
      #   only accept unix timestamp in milliseconds format.
      #   +single_use+: If set to true, token can only be use once.
      #
      # eg.
      #   identity.token(audience: ['auth'], exp: 1571296171000, nbf: 1571296171000, single_use: true)
      #   # => return token string
      #
      def token(audience: [], exp: nil, nbf: nil, single_use: false)
        payload = { identity: { id: id },
                    audience: audience,
                    expiry_date: exp,
                    single_use: single_use,
                    nbf: nbf }
        perform_post_and_parse(EXCEPTION, path('/token/generate'),
                               payload.to_json)['token']
      end

      class << self
        # identity not supporting this method
        def find
          raise NotImplementedError
        end

        # identity not supporting this method
        def find_by_id
          raise NotImplementedError
        end

        # Create identity
        # Required parameters:
        #   +name+: The name of identity. This is required for login/generate token
        #   +principal_id+: This id can be extract from Principal class. This is required for login/generate token
        #
        # Options:
        #   +secret+: Secret can be optional during identity creation but required for login. If secret is nil, random secret will be created.
        #   +skip_encryption+: This is only for migration purpose. PLEASE DONT SET THIS TO TRUE. Skip encryption basically disable the secret
        #   encryption.
        #   +privilege_ids+: an array of Privilege ids. To set the privilege/s of the identity
        #   +role_ids+: an array of Role ids. To set the role/s of the identity
        #
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
        def create(name, principal_id, secret: nil, skip_encryption: false, privilege_ids: [], role_ids: [])
          payload = { name: name,
                      principal_id: principal_id,
                      skip_secret_encryption: skip_encryption,
                      secret: secret,
                      privileges: privilege_ids,
                      roles: role_ids }
          identity = super payload
          #  set attr that are not provided by api response
          identity.secret ||= secret
          identity.privilege_ids = privilege_ids
          identity.role_ids = role_ids
          identity
        end
      end

      private

      def path(*end_point)
        combine_path = end_point.flatten.compact.join
        [self.class.path, combine_path].join
      end
    end
  end
end
