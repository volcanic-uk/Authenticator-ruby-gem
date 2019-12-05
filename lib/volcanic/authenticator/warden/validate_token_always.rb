# frozen_string_literal: true

require 'warden'
require_relative 'strategy_helper'

module Volcanic::Authenticator::Warden
  # this strategy validate token always.
  # if authorization header not present or missing, it fail the request
  class ValidateTokenAlways < Warden::Strategies::Base
    include StrategyHelper

    def authenticate!
      # if request already being halted dont run this strategy
      return if halted?

      # fail! this strategy for missing authorization header
      return fail! missing_message unless token_exist?

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
