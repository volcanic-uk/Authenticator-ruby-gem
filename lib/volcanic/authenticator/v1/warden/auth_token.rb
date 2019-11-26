# frozen_string_literal: true

require_relative 'auth_strategy'

module Volcanic::Authenticator
  module V1::Warden
    # A strategy class for warden. this strategy authenticate token always
    class AuthToken < AuthStrategy
      def authenticate!
        # if request already being halted dont run this strategy
        return if halted?

        # fail! this strategy for missing authorization header
        return missing! if auth_token.empty?

        validate_token
      end
    end
  end
end
