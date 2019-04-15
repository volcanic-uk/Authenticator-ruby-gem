require 'redis'
require 'time'

module Volcanic::Authenticator

  class Cache

    def initialize
      @redis = Redis.new(url: URL)
    end

    # Validate token, return bool
    def valid?(token)
      t = perform_get(token)
      return false if t.nil?
      return false if Time.parse(t) < Time.now
      true
    end

    # Store token to cache
    def set(token)
      return "OK" if valid? token
      perform_set token
    end

    def delete(token)
      perform_del token
    end

    # Clear all token at cache
    def clear
      @redis.keys.each(&method(:perform_del))
    end

    # Get all token at Cache
    def get_all
      @redis.keys
    end

    private

    # setup redis table/data
    # def configure
    #   return unless @redis.get(KEY).nil?
    #   perform_set []
    # end

    def perform_get(key)
      @redis.get key
    end

    def perform_set(key)
      @redis.set key, Time.now
    end

    def perform_del(token)
      @redis.del token
    end

    # def append_token(token)
    #   return [] if token.empty?
    #   token_array = JSON.parse perform_get
    #   token_array << {
    #       token: token,
    #       expire: Time.now
    #   }
    #   token_array
    # end

  end

end
