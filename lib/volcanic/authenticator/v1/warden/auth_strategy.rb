require 'warden'
require 'forwardable'
require_relative '../token'

module Volcanic::Authenticator
  module V1
    module Warden
      class AuthStrategy < Warden::Strategies::Base
        extend Forwardable
        def_delegator 'Volcanic::Authenticator.config'.to_sym, :validate_token, :validate_token_when_presented

        def authenticate!
          return missing! if validate_token && auth_token.empty?

          return success! '' if validate_token_when_presented && auth_token.empty?

          return success! '' if all_options_disabled?

          token = Volcanic::Authenticator::V1::Token.new(auth_token)
          if token.remote_validate
            success!(token)
          else
            invalid!
          end
        rescue Volcanic::Authenticator::V1::TokenError
          invalid!
        rescue Volcanic::Authenticator::V1::ConnectionError => e
          fail!(e)
        end

        private

        def auth_token
          env['HTTP_AUTHORIZATION'].to_s.gsub('Bearer ', '')
        end

        def invalid!
          fail! 'Authorization header is invalid!'
        end

        def missing!
          fail! 'Authorization header is missing!'
        end

        def all_options_disabled?
          !validate_token && !validate_token_when_presented
        end
      end
    end
  end
end