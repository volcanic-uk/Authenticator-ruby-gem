require 'volcanic/authenticator/v1/cache'
require 'volcanic/authenticator/v1/connection'

module Volcanic
  module Authenticator

    # Request new identity
    def self.create_identity(name= nil, ids= [])
      Connection.new.identity({name: name, ids: ids})
    end

    # Request new authority
    def self.create_authority(name)
      Connection.new.authority({name: name})
    end

    # Request new authority group
    def self.create_group(name, authorities = [])
      Connection.new.group({name: name, authorities: authorities})
    end

    # Request new token
    def self.create_token(name, secret)
      Connection.new.token({name: name, secret: secret})
    end
    #
    # # Validate token at cache and at Auth service
    # def self.validate_token(token)
    #   Connection.new.validate(token)
    # end
    #
    # # Delete token at cache and AAG
    # def self.delete_token(token)
    #   Connection.new.delete(token)
    # end
    #
    # #clear cache token
    # def self.clear
    #   Cache.clear
    # end
    #
    # #clear cache token
    # def self.list
    #   Cache.get_all
    # end

  end
end
