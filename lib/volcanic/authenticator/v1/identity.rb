require 'httparty'
require 'forwardable'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/header'
require 'volcanic/authenticator/v1/token'

module Volcanic
  module Authenticator
    module V1
      ##
      # This class contains all Authenticator method
      class Identity
        extend SingleForwardable
        extend Forwardable

        include HTTParty
        include Volcanic::Authenticator::V1::Response
        include Volcanic::Authenticator::V1::Header

        # URLS
        IDENTITY_REGISTER = '/api/v1/identity'.freeze
        IDENTITY_LOGIN = '/api/v1/identity/login'.freeze
        IDENTITY_LOGOUT = '/api/v1/identity/logout'.freeze
        IDENTITY_DEACTIVATE = '/api/v1/identity/deactivate'.freeze
        IDENTITY_VALIDATE = '/api/v1/identity/validate'.freeze
        PUBLIC_KEY = '/api/v1/key/public'.freeze

        # constant
        PKEY = 'pkey'.freeze
        APP_TOKEN = 'application_token'.freeze

        def_delegators :instance, :register, :login, :logout, :deactivate, :validation, :name, :secret, :id, :source_id, :token
        def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
        def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :exp_app_token, :exp_public_key

        attr_reader :name, :secret, :id, :source_id, :token

        @_singleton_mutex = Mutex.new

        class << self
          ##
          # singleton class
          def instance
            @_singleton_mutex.synchronize { @_singleton_instance ||= new }
          end
        end

        def initialize(name = nil, password = nil, ids = [])
          self.class.base_uri Volcanic::Authenticator.config.auth_url
          register(name, password, ids) unless name.nil?
        end

        def register(name, password = nil, ids = [])
          payload = { name: name, ids: ids, password: password }
          res = request_post IDENTITY_REGISTER, payload, bearer_header(app_token)
          _, @name, @secret, @id = build_response res, 'identity'
        end

        def login(name, secret)
          payload = { name: name, secret: secret }
          res = request_post IDENTITY_LOGIN, payload, bearer_header(app_token)
          _, @token, @source_id = build_response res, 'token'
          @name, @secret = [name, secret]
          caching @token, exp_token # cache token key and value with exp time
        end

        def logout(token)
          res = request_post IDENTITY_LOGOUT, { token: token }, bearer_header(token)
          raise_exception_if_error res
          cache_remove! export_token_id(token)
          remove_token_attr
        end

        def deactivate(identity_id, token)
          res = request_post "#{IDENTITY_DEACTIVATE}/#{identity_id}", nil, bearer_header(token)
          raise_exception_if_error res
          cache_remove! export_token_id(token)
          remove_all_attr
        end

        def validation(token)
          return true if token_exists? token

          res = request_post IDENTITY_VALIDATE, { token: token }, bearer_header(token)
          raise_exception_if_error res
          caching(token, exp_token)
          true
        rescue TokenError
          false
        end

        private

        def pkey
          cache.fetch PKEY, expire_in: exp_public_key, &method(:public_key_request)
        end

        def app_token
          cache.fetch APP_TOKEN, expire_in: exp_app_token, &method(:main_token_request)
        end

        def public_key_request
          res = request_get PUBLIC_KEY, nil, bearer_header(main_token_request)
          pem = build_response res, 'pkey'
          generate_pkey(pem)
        end

        def main_token_request
          payload = { name: Volcanic::Authenticator.config.app_name,
                      secret: Volcanic::Authenticator.config.app_secret }
          res = request_post IDENTITY_LOGIN, payload
          _, token, = build_response res, 'app_token'
          token
        end

        def generate_pkey(pem)
          OpenSSL::PKey.read(pem)
        end

        def export_token_id(token)
          Token.new(token, pkey).jti
        end

        def caching(value, exp)
          key = export_token_id value
          cache.fetch key, expire_in: exp do
            value
          end
        end

        def cache_exists?(key)
          cache.key? key
        end

        def cache_remove!(key)
          cache.evict! key
        end

        def request_post(url, body, header = nil)
          self.class.post(url, body: body.to_json, headers: header)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError
          raise URLError
        end

        def request_get(url, body, header = nil)
          self.class.get(url, body: body.to_json, headers: header)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError
          raise URLError
        end

        def token_exists?(token)
          cache_exists? export_token_id(token)
        end

        def remove_token_attr
          @token = nil
          @source_id = nil
        end

        def remove_all_attr
          @name = nil
          @secret = nil
          @id = nil
          @token = nil
          @source_id = nil
        end
      end
    end
  end
end
