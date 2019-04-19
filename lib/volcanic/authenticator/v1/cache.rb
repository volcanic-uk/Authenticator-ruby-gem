require 'redis'
require 'time'
require 'volcanic/authenticator/v1/token'

module Volcanic
  module Authenticator

  class Cache

    include Volcanic::Authenticator::Token
    attr_accessor :token

    def initialize(token= nil)
      @redis = Redis.new(url: ENV['volcanic_authentication_redis'] || "redis://localhost:6379/1")
      @token = token
    end

    # Validate token, return bool
    def valid?
      return false if @token.nil?
      exp = perform_get # get expiry time of token
      return false if exp.nil?
      return false if Time.at(exp.to_i) < Time.now
      true
      # exp.nil?
    end

    # Store token to cache
    def save
      return nil if @token.nil?
      return "OK" if valid?
      perform_set
    end

    def delete
      return nil if @token.nil?
      perform_del @token
    end

    # Clear all token at cache
    def clear_all
      perform_clear_all
    end

    # Get all token at Cache
    def get_all
      perform_get_all
    end

    private

    def perform_get
      @redis.get @token
    end

    def perform_set
      @redis.set @token, expiry_time(@token)
    end

    def perform_del(token)
      @redis.del token
    end

    def perform_clear_all
      @redis.keys.each(&method(:perform_del))
    end

    def perform_get_all
      @redis.keys
    end

  end
  end
end
