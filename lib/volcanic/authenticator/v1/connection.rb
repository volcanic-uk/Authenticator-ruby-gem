require 'httparty'
require 'redis'
require 'dotenv/load'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/header'

module Volcanic::Authenticator
  class Connection
    include HTTParty
    include Response
    include Header

    base_uri ENV['volcanic_authentication_domain']
    # default_timeout 30 #hard timeout

    def identity(payload, header= nil)
      res = request '/api/v1/identity', payload, header, 'POST'
      return_identity res
    end

    def authority(payload, header= nil)
      res = request '/api/v1/authority', payload, header, 'POST'
      return_authority res
    end

    def group(payload, header= nil)
      res = request '/api/v1/group', payload, header, 'POST'
      return_group res
    end

    def token(payload, header= nil)
      res = request '/api/v1/identity/login', payload, header, 'POST'
      return_token res
    end

    def validate(token)
      return true if token_valid? token
      res = request '/api/v1/identity/login', nil, bearer_header(token), 'POST'
      token res
      res.success?
    end

    def delete(token)
      res = request '/api/v1/token', nil, bearer_header(token), 'DELETE'
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

    def token_valid?(token)
      Cache.new(token).valid?
    end

    def delete_cache(token)
      Cache.new(token).delete
    end

  end
end
