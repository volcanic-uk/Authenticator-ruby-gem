require 'httparty'
require_relative 'error_response'
require_relative 'header'
require_relative 'token'
require_relative 'token_key'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    ##
    # This class contains all Identity method => :register, :login, :logout, :validate, :deactivate
    class Identity < Base
      extend Volcanic::Authenticator::V1::Header
      include Volcanic::Authenticator::V1::ErrorResponse
      extend Volcanic::Authenticator::V1::ErrorResponse

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
        url = Volcanic::Authenticator.config.auth_url
        payload = { name: @name,
                    secret: @secret }.to_json
        res = HTTParty.post "#{url}/#{IDENTITY_LOGIN}", body: payload
        raise_exception_identity(res) unless res.success?
        token = JSON.parse(res.body)['response']['token']
        Token.new(token).cache!
        token
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      class << self
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
          res = perform_request(IDENTITY_REGISTER, payload)
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
          res = perform_request(IDENTITY_LOGIN, payload)
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
          res = perform_request(IDENTITY_LOGOUT, payload, token)
          raise_exception_identity(res) unless res.success?
        end

        ##
        # Deactivate an identity and blacklist all associate tokens.
        # Eg.
        #   Identity.deactivate(1, 'eyJhbGciO...')
        #
        def deactivate(identity_id, token)
          cache.evict! token
          res = perform_request("#{IDENTITY_DEACTIVATE}/#{identity_id}", nil, token)
          raise_exception_identity(res) unless res.success?
        end

        ##
        # Check for token exist at cache and verify token signature,
        # If not exists in cache, it request to validate token
        # If invalid token signature, it return false
        #  Eg.
        #   Identity.validate(token)
        #   # => true/false
        #
        def validate(token)
          return true if cache.key?(token) && Token.new(token).verify!

          payload = { token: token }.to_json
          res = perform_request(IDENTITY_VALIDATE, payload, token)
          res.success?
        end

        private

        def perform_request(end_point, body, header = TokenKey.fetch_and_request_app_token)
          url = Volcanic::Authenticator.config.auth_url
          HTTParty.post "#{url}/#{end_point}", body: body, headers: bearer_header(header)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
          raise ConnectionError, e
        end
      end
    end
  end
end
