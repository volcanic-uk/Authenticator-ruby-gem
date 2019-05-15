require 'httparty'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/header'
require 'volcanic/authenticator/v1/token'

module Volcanic
  module Authenticator
    module V1
      ##
      # This class contains all Authenticator method
      class Identity
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

        attr_reader :name, :secret, :id, :source_id, :token

        def initialize(name = nil, password = nil, ids = [])
          self.class.base_uri Volcanic::Authenticator.config.auth_url
          register(name, password, ids) unless name.nil?
        end

        def register(name = @name, password = @password, ids = [])
          payload = { name: name, ids: ids, password: password }
          res = request_post IDENTITY_REGISTER, payload, bearer_header(app_token)
          _, @name, @secret, @id = build_response res, 'identity'
        end

        def login(name = @name, secret = @secret)
          payload = { name: name, secret: secret }
          res = request_post IDENTITY_LOGIN, payload, bearer_header(app_token)
          @name, @secret = [name, secret]
          _, @token, @source_id = build_response res, 'token'
          caching @token, cache_token_exp_time # cache token key and value with exp time
        end

        def logout(token = @token)
          res = request_post IDENTITY_LOGOUT, { token: token }, bearer_header(token)
          cache_remove! export_token_id(token)
          remove_token_attr if res.success?
          'OK'
        end

        def deactivate(identity_id = @id, token = @token)
          res = request_post "#{IDENTITY_DEACTIVATE}/#{identity_id}", nil, bearer_header(token)
          cache_remove! export_token_id(token)
          remove_all_attr if res.success?
          'OK'
        end

        def validation(token = @token)
          return true if token_exists? token

          res = request_post IDENTITY_VALIDATE, { token: token }, bearer_header(token)
          if res.success?
            caching(token, cache_token_exp_time)
            return true
          end

          false
        rescue InvalidToken
          false
        end

        private

        def cache
          Volcanic::Cache::Cache.instance
        end

        def cache_token_exp_time
          Volcanic::Authenticator.config.exp_token
        end

        def cache_app_token_exp_time
          Volcanic::Authenticator.config.exp_app_token
        end

        def cache_pkey_exp_time
          Volcanic::Authenticator.config.exp_public_key
        end

        def pkey
          cache.fetch PKEY, expire_in: cache_pkey_exp_time, &method(:public_key_request)
        end

        def app_token
          cache.fetch APP_TOKEN, expire_in: cache_app_token_exp_time, &method(:main_token_request)
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
        end

        def request_get(url, body, header = nil)
          self.class.get(url, body: body.to_json, headers: header)
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
