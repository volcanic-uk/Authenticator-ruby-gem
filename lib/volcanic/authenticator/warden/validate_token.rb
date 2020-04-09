# frozen_string_literal: true

require 'warden'
require_relative 'strategy_helper'

module Volcanic::Authenticator::Warden
  # this strategy validate token always.
  # if authorization header not present or missing, it fail the request
  class ValidateToken < Warden::Strategies::Base
    include StrategyHelper

    def valid?
      auth_header_exist? # only run strategy when auth header present
    end

    def authenticate!
      # if token nil or in wrong format it raise TokenError
      self.token = auth_token
      validate_token
    rescue Volcanic::Authenticator::V1::TokenError, Volcanic::Authenticator::V1::AuthenticationError => e
      logger.debug("#{e.class.name}: #{e}")
      fail! invalid_message
    end
  end
end
