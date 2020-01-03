# frozen_string_literal: true

require_relative 'token'

module Volcanic::Authenticator
  module V1
    # Contains similar behaviour to +Token+ as it
    # extending to Token class. Extra features:
    #  +remove_validate+ will store the result into cache,
    #  and reuse it again until it expired.
    #  +revoke!+ will remove the result if exists in cache, and proceed
    #  with revoking the token.
    class TokenCache < Token
      # cache +remote_validate+ result
      def remote_validate
        cache.fetch token_base64, expire_at: exp do
          super
        end
      end

      # remove cache for this token and revoke it
      def revoke!
        cache.evict! token_base64 unless token_base64.nil?
        super
      end
    end
  end
end
