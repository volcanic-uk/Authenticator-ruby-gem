# frozen_string_literal: true

require_relative 'auth_strategy'

module Volcanic::Authenticator
  module V1::Warden
    # A strategy class for warden. this strategy authenticate token when it presented
    class AuthTokenWhenPresented < AuthStrategy
      def authenticate!
        # if request already being halted dont run this strategy
        return if halted?

        # success! this strategy for missing authorization header
        return success! '' if auth_token.empty?

        validate_token
      end
    end
  end
end
