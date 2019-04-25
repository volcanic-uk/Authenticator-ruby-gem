require 'httparty'
require 'redis'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/header'

module Volcanic
  module Authenticator
    # Connection class
    class Connection
      include HTTParty
      include Volcanic::Authenticator::Response
      include Volcanic::Authenticator::Header

      def initialize
        self.class.base_uri ENV['vol_auth_domain'] || 'http://localhost:3000'
      end

      def identity(payload)
        res = request('/api/v1/identity',
                      payload,
                      bearer_header,
                      'POST')
        build_response res, 'identity'
      end

      def deactivate_identity(identity_id, token)
        res = request("/api/v1/identity/deactivate/#{identity_id}",
                      nil,
                      bearer_header(token),
                      'POST')
        res.success?
      end

      def token(payload)
        res = request('/api/v1/identity/login',
                      payload,
                      nil,
                      'POST')
        build_response res, 'token'
      end

      def validate(token)
        return true if token_valid? token

        res = request('/api/v1/identity/validate',
                      { token: token },
                      bearer_header(token),
                      'POST')
        return false unless res.success?

        caching JSON.parse(res.body)['token']
        true
      end

      def delete(token)
        res = request('/api/v1/identity/logout',
                      { token: token },
                      bearer_header(token),
                      'POST')
        delete_cache token
        res.success?
      end

      def authority(payload)
        res = request('/api/v1/authority',
                      payload,
                      bearer_header,
                      'POST')
        build_response res, 'authority'
      end

      def group(payload)
        res = request('/api/v1/group',
                      payload,
                      bearer_header,
                      'POST')
        build_response res, 'group'
      end

      def public_key
        res = request('/api/v1/key/public',
                      nil,
                      bearer_header,
                      'GET')
        build_response res, 'key'
      end

      def main_token
        name = ENV['vol_auth_identity_name'] || 'volcanic'
        secret = ENV['vol_auth_identity_secret'] || '3ddaac80b5830cef8d5ca39d958954b3f4afbba2'
        res = request('/api/v1/identity/login',
                      { name: name, secret: secret },
                      nil,
                      'POST')
        build_response res, 'mtoken'
      end

      private

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
