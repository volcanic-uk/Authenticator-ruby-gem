require 'volcanic/authenticator/v1/cache'
require 'volcanic/authenticator/v1/connection'
require 'volcanic/authenticator/v1/header'
require 'volcanic/authenticator/v1/response'
require 'volcanic/authenticator/v1/token'

module Volcanic
  module Authenticator
    
    # Request new identity
    def self.create_identity(name, ids= [])
      Connection.new.identity({name: name, ids: ids})
    end

    # Request new authority
    def self.create_authority(name, creator_id)
      Connection.new.authority({name: name, creator_id: creator_id})
    end

    # Request new authority group
    def self.create_group(name, creator_id, authorities = [])
      Connection.new.group({name: name, creator_id: creator_id, authorities: authorities})
    end

    # Request new token
    def self.create_token(name, secret)
      Connection.new.token({name: name, secret: secret})
    end

    # Validate token at cache and at Auth service
    def self.validate_token(token)
      Connection.new.validate(token)
    end

    # Delete token at cache and Auth service
    def self.delete_token(token)
      Connection.new.delete(token)
    end

    #clear cache token
    def self.clear
      # Cache.new.clear
    end

    #clear cache token
    def self.list
      # Cache.new.get_all
    end

    def self.decode_token(token)
      # Token.new(token).expiry_time
    end

  end
end
