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
        raise_exception_if_error res, 'token'
        token = JSON.parse(res.body)['response']['token']
        Token.new(token).caching!
        token
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      class << self
        ##
        # Register/Create new Identity
        def register(name, secret = nil, principal_id = nil, ids = [])
          payload = { name: name,
                      principal_id: principal_id,
                      password: secret,
                      ids: ids }.to_json
          res = perform_request(IDENTITY_REGISTER, payload)
          raise_exception_if_error res
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['principal_id'], parser['secret'], parser['id'])
        end

        ##
        # Login identity and generate token
        def login(name, secret)
          payload = { name: name, secret: secret }.to_json
          res = perform_request(IDENTITY_LOGIN, payload)
          raise_exception_if_error res, 'token'
          token = JSON.parse(res.body)['response']['token']
          Token.new(token).caching!
          token
        end

        ##
        # Logout identity and blacklist token.
        def logout(token)
          cache.evict! token
          payload = { token: token }.to_json
          res = perform_request(IDENTITY_LOGOUT, payload, token)
          raise_exception_if_error res
        end

        ##
        # Deactivate identity and blacklist all associate tokens.
        def deactivate(identity_id, token)
          cache.evict! token
          res = perform_request("#{IDENTITY_DEACTIVATE}/#{identity_id}", nil, token)
          raise_exception_if_error res
        end

        ##
        # Validate token exists at cache or valid signature.
        def validate(token)
          Token.new(token).valid?
          return true if cache.key? token

          payload = { token: token }.to_json
          res = perform_request(IDENTITY_VALIDATE, payload, token)
          res.success?
        rescue TokenError
          false
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
