# frozen_string_literal: true

require 'warden/strategies/base'
require 'forwardable'
require_relative '../token'

module Volcanic::Authenticator
  module V1
    module Warden
      # this class handle the auth service authentication by using warden
      class AuthStrategy < Warden::Strategies::Base
        extend Forwardable
        def_delegator 'Volcanic::Authenticator.config'.to_sym, :validate_token_always, :validate_token_when_presented

        def authenticate!
          # check for which options is enabled
          validate_when_required

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

        # 4 cases will be check here base on 2 options
        # +validate_token_always+ and +validate_token_when_presented+
        # 1st: validate_token_always is enabled and token is empty.
        #   this return invalid with missing message
        # 2nd: validate_token_when_presented and token is exists
        #   proceed the validation
        # 3rd: validate_token_when_presented and token is empty
        #   return success without validating token
        # 4th: validate_token_always and validate_token_when_presented is disabled
        #   return success without validating token
        def validate_when_required
          return missing! if validate_token_always && auth_token.empty?

          return success! '' if validate_token_when_presented && auth_token.empty?

          return success! '' if all_options_disabled?

          nil
        end

        def all_options_disabled?
          !validate_token_always && !validate_token_when_presented
        end
      end
    end
  end
end
