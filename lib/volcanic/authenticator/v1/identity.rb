# frozen_string_literal: true

require_relative 'common_principal_identity'
require_relative 'token'

module Volcanic::Authenticator
  module V1
    # Identity API
    class Identity < CommonPrincipalIdentity
      attr_accessor :id, :name, :secret, :privilege_ids, :role_ids
      attr_reader :secure_id, :principal_id, :dataset_id, :source, :created_at, :updated_at

      # identity base path
      def self.path
        'api/v1/identity'
      end

      # setting the exception method
      def self.exception
        :raise_exception_identity
      end

      def initialize(**opts)
        %i[id secure_id name secret principal_id dataset_id source created_at updated_at].each do |key|
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
        parsed = perform_post_and_parse self.class.exception, path('/secret/reset/', id), payload
        self.secret = parsed['secret'] || new_secret
      end

      # login. retrieve token when credential is provided
      #
      # eg.
      #   Identity.new(name: 'abc@123.com', secret: 'abc123', principal_id: 1).login
      #   or
      #   opts = { name: 'abc@123.com', secret: 'abc123' }
      #   Identity.new(opts).login('service-a', 'abc123')
      #   # => return token object
      #
      def login(*audience)
        payload = { name: name,
                    secret: secret,
                    dataset_id: dataset_id,
                    audience: audience.flatten.compact }
        request_token '/login', payload, nil
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
      #   # => return token object
      #
      # NOTE: exp date will only accept maximum time of 1 day from the current time.
      def token(audience: [], exp: nil, nbf: nil, single_use: false)
        payload = { identity: { id: id },
                    audience: audience,
                    expiry_date: exp,
                    single_use: single_use,
                    nbf: nbf }
        request_token '/token/generate', payload
      end

      class << self
        # Create identity
        # Required parameters:
        #   +name+: The name of identity. This is required for login/generate token
        #   +principal_id+: this is the secure id of Principal
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
        #   Identity.create('name', principal_id, privileges: privileges roles: roles)
        #
        #   # Source
        #   # identity can be created with a source options, eg 'facebook' or 'linkedIn'.
        #   # note that, this will generate a secretless identity.
        #   Identity.create('name', principal_id, source: 'google')
        #
        #  # Secretless
        #  # identity can be secretless, which mean it wont have a secret if this set to true
        #  # by default if source is set to 'password', secretless will be set to false.
        #  Identity.create('name', principal_id, source: 'google', secretless: true)
        #   OR
        #  Identity.create('name', principal_id, source: 'password') # secretless false
        #  Identity.create('name', principal_id, source: 'google') # secretless true
        #
        def create(name, principal_id, **opts)
          payload = payload_handler(**opts)
          payload[:name] = name
          payload[:principal_id] = principal_id
          identity = super payload
          # TODO: (AUTH-215) remove this when auth returning the correct id (secure_id)
          identity.id = identity.secure_id unless identity.secure_id.nil?
          #  set attributes that are not provided by the api response
          identity.secret ||= payload[:secret]
          identity.privilege_ids = payload[:privileges]
          identity.role_ids = payload[:roles]
          identity
        end

        private

        # by default identity will have source with value `password` and secretless false.
        # if source is set to others value, secretless will force to be true.
        # if source is nil, default value will be taken.
        # if source is empty, it raise IdentityError.
        # if secretless provided, it follows
        def payload_handler(**opts)
          {
            source: source = opts[:source] || 'password',
            secret: opts[:secret],
            skip_secret_encryption: opts[:skip_encryption] || false,
            privileges: opts[:privilege_ids] || [],
            roles: opts[:role_ids] || [],
            secretless: opts[:secretless].nil? ? source.to_s != 'password' : opts[:secretless] # secretless will be false if source is 'password'
          }
        end
      end

      private

      def path(*end_point)
        combine_path = end_point.flatten.compact.join
        [self.class.path, combine_path].join
      end

      # this method request to auth service and returning it as Token object
      def request_token(endpoint, payload, auth_token = AppToken.fetch_and_request)
        payload.delete_if { |_, value| value.nil? } # delete nil value hash
        token = perform_post_and_parse(self.class.exception, path(endpoint),
                                       payload.to_json, auth_token)['token']
        Token.new(token)
      end
    end
  end
end
