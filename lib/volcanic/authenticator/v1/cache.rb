require 'redis'
require 'time'
require 'volcanic/authenticator/v1/token'

module Volcanic
  module Authenticator
    # Cache class
    class Cache
      include Volcanic::Authenticator::Token
      PKEY = 'public_key'.freeze

      def initialize
        @redis = Redis.new(url: redis_url)
      end

      # Validate token, return bool
      def valid?(token)
        exp = perform_get token
        return false if exp.nil?

        if Time.at(exp.to_i) < Time.now # if token is expired
          delete_token token
          return false
        end

        true
      end

      # Store token to cache
      def save_token(token)
        return if valid? token

        perform_set token
      end

      def save_pkey(key)
        perform_set key, false
      end

      def delete_token(token)
        return nil if token.nil?

        perform_del token
      end

      def delete_pkey
        perform_del
      end

      # Clear all token at cache
      def clear_all
        perform_clear_all
      end

      # Get all token at Cache
      def list_all
        perform_get_all
      end

      private

      def redis_url
        ENV['vol_auth_redis'] || 'redis://localhost:6379/1'
      end

      def perform_get(token)
        @redis.get token
      end

      def perform_set(value, is_token = true)
        if is_token
          # set token
          @redis.set value, expiry_time(value)
          @redis.expire value, (ENV['vol_auth_redis_exp_token_time'] || 5) * 60 # token is deleted when expired.
        else
          # set public key
          @redis.set PKEY, value
          @redis.expire value, (ENV['vol_auth_redis_exp_pkey_time'] || 1) * 24 * 60 * 60 # public key is deleted when expired.
        end
      end

      def perform_del(token = nil)
        @redis.del PKEY if token.nil? # delete public key
        @redis.del token # delete token
      end

      def perform_clear_all
        @redis.keys.each(&method(:perform_del)) # delete each tokens
      end

      def perform_get_all
        keys = @redis.keys # get all tokens
        keys.pop PKEY
        keys
      end
    end
  end
end
