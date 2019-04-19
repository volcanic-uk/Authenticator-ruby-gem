require 'volcanic/authenticator/v1/connection'

module Volcanic
  module Authenticator

    # Request new identity
    def self.generate_identity(name, ids= [])
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
    def self.generate_token(name, secret)
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
    # def self.clear
    #   Cache.new.clear
    # end

    #clear cache token
    # def self.list
    #   Cache.new.get_all
    # end

  end
end
