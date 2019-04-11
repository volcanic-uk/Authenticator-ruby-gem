require 'redis'

module Volcanic::Authenticator

  class Cache

    KEY = 'volcanic-authenticator-gem'

    def initialize
      @redis = Redis.new
      configure
    end

    # Validate token, return bool
    def valid?(token)
      perform_get.include?(token)
    end

    # Store token to cache
    def set(token)
      return "OK" if valid? token
      perform_set token
    end

    # Clear all token at cache
    def clear
      perform_set []
    end

    # Get all token at Cache
    def get_all
      perform_get
    end

    private

    # setup redis table/data
    def configure
      return unless @redis.get(KEY).nil?
      perform_set []
    end

    def perform_get
      @redis.get KEY
    end

    def perform_set(token)
      @redis.set KEY, append_token(token)
    end

    def append_token(token)
      return [] if token.empty?
      token_array = JSON.parse perform_get
      token_array << token
      token_array
    end

  end

end
