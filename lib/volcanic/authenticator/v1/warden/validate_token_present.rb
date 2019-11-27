# frozen_string_literal: true

require_relative '../token'
require_relative 'strategy_helper'

module Volcanic::Authenticator
  module V1::Warden
    # this strategy validate when only authorization header is presented.
    # if present or missing, it will not fail the request.
    # if present and invalid token, it fail request
    class ValidatePresentToken < Warden::Strategies::Base
      include StrategyHelper

      def authenticate!
        # if request already being halted dont run this strategy
        return if halted?

        # success! this strategy for missing authorization header
        return success! '' unless token_exist?

        if token_valid?
          success! token
        else
          fail! invalid_message
        end
      rescue Volcanic::Authenticator::V1::TokenError
        fail! invalid_message
      end
    end
  end
end
