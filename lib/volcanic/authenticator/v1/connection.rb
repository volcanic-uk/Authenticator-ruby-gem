require 'httparty'
require 'redis'
require 'dotenv/load'

module Volcanic::Authenticator
  class Connection
    include HTTParty
    base_uri ENV['AUTHENTICATOR_DOMAIN'] || ENV['auth_domain']
    # default_timeout 30 #hard timeout

    def identity(payload, header= nil)
      res = request '/api/v1/identity', payload, header, 'POST'
      Response.identity res
    end

    def authority(payload, header= nil)
      res = request '/api/v1/authority', payload, header, 'POST'
      Response.authority res
    end

    def group(payload, header= nil)
      res = request '/api/v1/group', payload, header, 'POST'
      Response.group res
    end

    def token(payload, header= nil)
      res = request '/api/v1/authenticate', payload, header, 'POST'
      Response.token res
    end

    def validate(token)
      return true if token_exists? token
      res = request '/api/v1/token', nil, token, 'GET'
      Response.token res
      res.success?
    end

    def delete(token)
      # return true unless token_exists? token
      res = request '/api/v1/token', nil, token, 'DELETE'
      delete_cache token
      res.success?
    end

    private

    def request(url, payload, header, method)

      case method
      when 'POST'
        respond = self.class.post(url, body: payload.to_json, headers: header)
      when 'DELETE'
        respond = self.class.delete(url, body: payload.to_json, headers: header)
      else
        respond = self.class.get(url, body: payload.to_json, headers: header)
      end

      respond
    end

    def token_exists?(token)
      Cache.new.valid? token
    end

    def delete_cache(token)
      Cache.new.delete token
    end

  end
end
