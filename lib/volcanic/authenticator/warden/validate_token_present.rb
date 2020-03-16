# frozen_string_literal: true

require 'warden'
require_relative 'strategy_helper'

module Volcanic::Authenticator::Warden
  # this strategy validate when only authorization header is presented.
  # if present or missing, it will not fail the request.
  # if present and invalid token, it fail request
  class ValidatePresentToken < Warden::Strategies::Base
    include StrategyHelper

    def valid?
      true # allow to run strategy even auth header is nil
    end

    def authenticate!
      # if token nil or in wrong format if raise TokenError
      if auth_header_exist?
        self.token = auth_token
        validate_token
      else
        logger.debug 'No token was provided with request - not checking for auth'
        pass
      end
    rescue Volcanic::Authenticator::V1::TokenError => e
      logger.debug("#{e.class.name}: #{e}")
      pass
    end
  end
end
