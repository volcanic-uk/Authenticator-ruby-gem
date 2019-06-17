require_relative 'error'
require_relative 'request'
require_relative 'token'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    ##
    # Handle identity api
    # method => :register, :login, :logout, :validate, :deactivate
    # attr => :name, :secret, :id, :principal_id, token
    class Identity < Base
      include Request
      include Error

      attr_reader :name, :secret, :id, :principal_id

      def initialize(name = nil, principal_id = nil, secret = nil, id = nil)
        @name = name
        @principal_id = principal_id
        @secret = secret
        @id = id
      end

      ##
      # Generally this is login
      def token
        payload = { name: @name,
                    secret: @secret }.to_json
        res = perform_post_request(IDENTITY_LOGIN, payload, nil)
        raise_exception_identity(res) unless res.success?
        token = JSON.parse(res.body)['response']['token']
        Token.new(token).cache!
        token
      end

      class << self
        include Request
        include Error
        ##
        # Register an identity.
        # Only require a name.
        # Eg.
        #   identity = Identity.register('name')
        #   identity.name # => 'name'
        #   identity.secret # => <GENERATED_SECRET>
        #   identity.principal_id # => nil
        #   identity.id # => <GENERATED_ID>
        #
        # #####################################
        #
        #  # register with secret and principal_id
        # Eg.
        #   identity = Identity.register('name', 'secret', 1)
        #
        def register(name, secret = nil, principal_id = nil)
          payload = { name: name,
                      principal_id: principal_id,
                      password: secret }.to_json
          res = perform_post_request(IDENTITY_REGISTER, payload)
          raise_exception_identity(res) unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['principal_id'], parser['secret'], parser['id'])
        end

        ##
        # Login an identity/Issue a token.
        # Need to pass the identity name and secret
        # Eg.
        #  Identity.login('name', 'secret')
        #  # => 'eyJhbGciO...'
        #
        def login(name, secret)
          payload = { name: name, secret: secret }.to_json
          res = perform_post_request(IDENTITY_LOGIN, payload, nil)
          raise_exception_identity(res) unless res.success?
          token = JSON.parse(res.body)['response']['token']
          Token.new(token).cache!
          token
        end

        ##
        # Logout an identity and blacklist the token.
        # Eg.
        #   Identity.logout('eyJhbGciO...')
        #
        def logout(token)
          cache.evict! token
          payload = { token: token }.to_json
          res = perform_post_request(IDENTITY_LOGOUT, payload, token)
          raise_exception_identity(res) unless res.success?
        end

        ##
        # Deactivate an identity and blacklist all associate tokens.
        # Eg.
        #   Identity.deactivate(1, 'eyJhbGciO...')
        #
        def deactivate(identity_id, token)
          cache.evict! token
          res = perform_post_request("#{IDENTITY_DEACTIVATE}/#{identity_id}", nil, token)
          raise_exception_identity(res) unless res.success?
        end

        ##
        # Check for token exist at cache.
        # If not exists, it check verify token signature.
        # If verification pass, token is cache again.
        #  Eg.
        #   Identity.validate(token)
        #   # => true/false
        #
        def validate(auth_token)
          return true if cache.key?(auth_token)

          token = Token.new(auth_token)
          token.verify!
          token.cache!
          true
        rescue TokenError
          false
        end

        ##
        # Verify token remotely, by authenticator service.
        # Eg.
        #  Identity.remote_validate(token)
        #  # => true/false
        def remote_validate(auth_token)
          payload = { token: auth_token }.to_json
          res = perform_post_request(IDENTITY_VALIDATE, payload, auth_token)
          res.success?
        end
      end
    end
  end
end
