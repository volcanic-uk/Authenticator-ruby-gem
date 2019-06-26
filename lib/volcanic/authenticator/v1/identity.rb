require_relative 'error'
require_relative 'request'
require_relative 'token'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    ##
    # Handle identity api
    # method => :create, :delete
    # attr => :name, :secret, :id, :principal_id, token
    class Identity < Base
      include Request
      include Error

      # end-point
      IDENTITY_CREATE_URL = 'api/v1/identity'
      TOKEN_URL = 'api/v1/identity/login'
      IDENTITY_DELETE_URL = 'api/v1/identity/deactivate'

      attr_reader :name, :secret, :id, :principal_id

      def initialize(name = nil, secret = nil, id = nil, principal_id = nil)
        @name = name
        @principal_id = principal_id
        @secret = secret
        @id = id
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
        payload = { name: @name, secret: @secret }.to_json
        res = perform_post_request(TOKEN_URL, payload, nil)
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
        #   identity = Identity.register(name)
        #   identity.name # => 'name'
        #   identity.secret # => <GENERATED_SECRET>
        #   identity.principal_id # => nil
        #   identity.id # => <GENERATED_ID>
        #
        # #####################################
        #
        #  # register with secret and principal_id
        # Eg.
        #   identity = Identity.register(name, secret, principal_ids)
        #   # principals_ids = [1,2]
        #
        def create(name, secret = nil, principal_id = nil)
          payload = { name: name,
                      principal_id: principal_id,
                      password: secret }.to_json
          res = perform_post_request(IDENTITY_CREATE_URL, payload)
          raise_exception_identity(res) unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['secret'], parser['id'], parser['principal_id'])
        end
        ##
        # Deactivate an identity and blacklist all associate tokens.
        # Eg.
        #   Identity.delete(identity_id)
        #
        def delete(identity_id)
          res = perform_post_request("#{IDENTITY_DELETE_URL}/#{identity_id}", nil)
          raise_exception_identity(res) unless res.success?
        end
      end
    end
  end
end
