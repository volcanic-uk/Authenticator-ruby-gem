# frozen_string_literal: true

require_relative 'identity'

module Volcanic::Authenticator
  module V1
    # extending from Identity class.
    # Cache result for +login+ and +token+
    class IdentityCache < Identity
      def login(*audience)
        # use below credentials to create key
        key = gen_key(name, secret, dataset_id, audience)
        token = cache.fetch(key, expire_in: exp_token) do
          super(*audience)
        end

        update_cache_ttl key, token # update cache ttl
        token # return token object
      end

      def token(**opts)
        # dont cache if single use token
        return super(**opts) if opts[:single_use]

        key = gen_key(id, opts.map(&:last))
        token = cache.fetch(key, expire_in: exp_token) do
          super(**opts)
        end

        update_cache_ttl key, token # update cache ttl
        token # return token object
      end

      private

      # updating cache ttl to follow token expire period.
      # this method only run cache ttl and token expire is not equal.
      def update_cache_ttl(key, token)
        cache.update_ttl_for(key, expire_at: token.exp) unless cache.ttl_for(key) == (token.exp - Time.now.to_i)
      end

      # generate key string, for cache purpose.
      def gen_key(*opts)
        opts.compact.flatten.join(':')
      end
    end
  end
end
