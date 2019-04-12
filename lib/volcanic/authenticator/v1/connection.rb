require 'httparty'
require 'redis'
require 'dotenv/load'

module Volcanic::Authenticator
  class Connection
    include HTTParty
    base_uri ENV['AUTHENTICATOR_DOMAIN'] || ENV['auth_domain']
    # default_timeout 30 #hard timeout

    def identity(payload, header= nil)
      req = request '/api/v1/identity', options(payload, header), 'POST'
      req.body
    end

    def authority(payload, header= nil)
      req = request '/api/v1/authority', options(payload, header), 'POST'
      req.body
    end

    def group(payload, header= nil)
      req = request '/api/v1/group', options(payload, header), 'POST'
      req.body
    end

    def token(payload, header= nil)
      req = request '/api/v1/authenticate', options(payload, header), 'POST'
      caching req.body
      req.body
    end

    def validate(token)
      return true if token_exists? token
      req = request '/api/v1/token', options(nil, {
          Authorization: Header.bearer(token)
      }), 'GET'
      req.success?
    end

    def delete(token)
      # return true unless token_exists? token
      req = request '/api/v1/token', options(nil, {
          Authorization: Header.bearer(token)
      }), 'DELETE'
      req.success?
    end

    private

    def request(url, options, method, return_method = false)

      case method
      when 'POST'
        req = self.class.post(url, options)
      when 'DELETE'
        req = self.class.delete(url, options)
      else
        req = self.class.get(url, options)
      end

      return error(req.body, req.code) if req.bad_gateway?
      req
    end

    def caching(payload)
      token = JSON.parse(payload)['token']
      return if token.nil?
      Cache.new.set token
    end

    def token_exists?(token)
      Cache.new.valid? token
    end

    def options(payload, header)
      {
          body: payload,
          headers: header
      }
    end

    def error(msg, code)
      {
          error: {
              code: code,
              reason: msg.to_json
          }
      }
    end


  end
end
