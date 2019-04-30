require 'httparty'
require 'mini_cache'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/header'
require 'volcanic/authenticator/v1/token'

module Volcanic
  module Authenticator
    ##
    # This class contains all Authenticator method
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
      end

      def identity_register(name, ids = [])
        payload = { name: name, ids: ids }
        res = request(IDENTITY_REGISTER, payload, bearer_header(mtoken), 'POST')
        build_response res, 'identity'
      end

      def identity_login(name, secret)
        payload = { name: name, secret: secret }
        res = request(IDENTITY_LOGIN, payload, bearer_header(mtoken), 'POST')
        return res.body unless res.success?

        response, token = build_response res, 'token'
        caching(Token.new(token, pkey).jti,
                { token: token }.to_json,
                (ENV['vol_auth_cache_exp_external_token_time'].to_i || 5) * 60)
        response
      end

      def identity_logout(token)
        res = request(IDENTITY_LOGOUT,
                      { token: token },
                      bearer_header(token),
                      'POST')
        remove_cache Token.new(token, pkey).jti
        res.success?
      end

      def identity_deactivate(identity_id, token)
        res = request("/api/v1/identity/deactivate/#{identity_id}",
                      nil,
                      bearer_header(token),
                      'POST')
        remove_cache Token.new(token, pkey).jti
        res.success?
      end

      def identity_validate(token)
        return true if token_valid? token

        res = request('/api/v1/identity/validate',
                      { token: token },
                      bearer_header(token),
                      'POST')
        return false unless res.success?

        caching(Token.new(token, pkey).jti,
                { token: token }.to_json,
                (ENV['vol_auth_cache_exp_external_token_time'].to_i || 5) * 60)
        true
      end

      def authority_create(name, creator_id)
        payload = { name: name, creator_id: creator_id }
        res = request(AUTHORITY,
                      payload,
                      bearer_header(mtoken),
                      'POST')
        build_response res, 'authority'
      end

      def group_create(name, creator_id, authorities = [])
        payload = { name: name,
                    creator_id: creator_id,
                    authorities: authorities }
        res = request(GROUP,
                      payload,
                      bearer_header(mtoken),
                      'POST')
        build_response res, 'group'
      end

      def list_caches
        array = []
        @cache.each do |o|
          array << o
        end
        array
      end

      private

      def pkey
        @pkey ||= public_key_request
      end

      def mtoken
        @mtoken ||= main_token_request
      end

      def public_key_request
        p_key = @cache.get PKEY
        return p_key unless p_key.nil? # get public key from cache

        res = request('/api/v1/key/public',
                      nil,
                      bearer_header(@mtoken),
                      'GET')
        return nil unless res.success?

        build_response res, 'key'
        res_pkey = parser(res.body, %w[response key])
        caching PKEY, res_pkey, (ENV['vol_auth_cache_exp_internal_token_time'].to_i || 1) * 24 * 60 * 60
        res_pkey
      end

      def main_token_request
        m_token = @cache.get MTOKEN
        return m_token unless m_token.nil? # get public key from cache

        payload = { name: ENV['vol_auth_identity_name'] || 'volcanic',
                    secret: ENV['vol_auth_identity_secret'] || '3ddaac80b5830cef8d5ca39d958954b3f4afbba2' }
        res = request(IDENTITY_LOGIN,
                      payload,
                      nil,
                      'POST')
        return nil unless res.success?

        res_mtoken = parser(res.body, %w[response token])
        caching MTOKEN, res_mtoken, (ENV['vol_auth_cache_exp_internal_token_time'].to_i || 1) * 24 * 60 * 60
        res_mtoken
      end

      def caching(key, value, exp)
        return if key.nil?

        @cache.set key, value, expires_in: exp
      end

      def cache_exists?(key)
        @cache.get key
      end

      def remove_cache(key)
        return if key.nil?

        @cache.unset key
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

      def token_valid?(value)
        return false if value.nil?

        token = Token.new(value, pkey)
        return false if token.valid?

        exp = token.exp
        jti = token.jti
        return false unless cache_exists? jti

        if expiration_check exp
          delete_token jti
          return false
        end

        true
      end

      # Validate token, return bool
      def expiration_check(exp)
        Time.at(exp.to_i) < Time.now # if token is expired
      end
    end
  end
end
