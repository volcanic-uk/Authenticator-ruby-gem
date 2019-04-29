require 'httparty'
require 'mini_cache'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/header'

module Volcanic
  module Authenticator
    # method
    class Method
      include HTTParty
      include Volcanic::Authenticator::Response
      include Volcanic::Authenticator::Header
      # attr_accessor :pkey, :mtoken

      # URLS
      IDENTITY_REGISTER = '/api/v1/identity'.freeze
      IDENTITY_LOGIN = '/api/v1/identity/login'.freeze
      IDENTITY_LOGOUT = '/api/v1/identity/logout'.freeze
      IDENTITY_DEACTIVATE = '/api/v1/identity/deactivate/'.freeze
      IDENTITY_VALIDATE = '/api/v1/identity/validate'.freeze
      AUTHORITY = '/api/v1/authority'.freeze
      GROUP = '/api/v1/group'.freeze
      PUBLIC_KEY = '/api/v1/key/public'.freeze

      # constant
      PKEY = 'pkey'.freeze
      MTOKEN = 'mtoken'.freeze

      def initialize
        self.class.base_uri ENV['vol_auth_domain'] || 'http://localhost:3000'
        @cache = MiniCache::Store.new
        # public_key
        pkey
        mtoken
      end

      def identity_register(name, ids = [])
        payload = { name: name, ids: ids }
        res = request(IDENTITY_REGISTER, payload, bearer_header(@mtoken), 'POST')
        build_response res, 'identity'
      end

      def identity_login; end

      def identity_logout; end

      def identity_deactivate; end

      def identity_validate; end

      def authority_create; end

      def group_create; end

      private

      def pkey
        @pkey ||= public_key_request
      end

      def mtoken
        @mtoken ||= main_token_request
      end

      def public_key_request
        pkey = @cache.get PKEY
        return pkey unless pkey.nil? # get public key from cache

        res = request('/api/v1/key/public',
                      nil,
                      bearer_header(@mtoken),
                      'GET')
        return nil unless res.success?

        build_response res, 'key'

        res_pkey = parser(res.body, %w[response key])
        caching PKEY, res_pkey
        res_pkey
      end

      def main_token_request
        mtoken = @cache.get MTOKEN
        return mtoken unless mtoken.nil? # get public key from cache

        payload = { name: ENV['vol_auth_identity_name'] || 'volcanic',
                    secret: ENV['vol_auth_identity_secret'] || '3ddaac80b5830cef8d5ca39d958954b3f4afbba2' }
        res = request(IDENTITY_LOGIN,
                      payload,
                      nil,
                      'POST')
        return nil unless res.success?

        res_mtoken = parser(res.body, %w[response token])
        caching MTOKEN, res_mtoken
        res_mtoken
      end

      def caching(key, value)
        @cache.set key, value
      end

      def request(url, payload, header, method)
        case method
        when 'POST'
          self.class.post(url, body: payload.to_json, headers: header)
        when 'DELETE'
          self.class.delete(url, body: payload.to_json, headers: header)
        else
          self.class.get(url, body: payload.to_json, headers: header)
        end
      end

      def token_valid?(token)
        Cache.new.valid? token
      end

      def delete_cache(token)
        Cache.new.delete_token token
      end
    end
  end
end
