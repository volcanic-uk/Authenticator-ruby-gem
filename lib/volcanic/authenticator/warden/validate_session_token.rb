# frozen_string_literal: true

require 'warden'
require_relative 'strategy_helper'

module Volcanic::Authenticator::Warden
  # always authenticate session token
  class ValidateSessionToken < Warden::Strategies::Base
    include StrategyHelper

    def valid?
      session_token
    end

    def authenticate!
      self.token = session_token
      validate_token
    rescue Volcanic::Authenticator::V1::TokenError => e
      logger.debug("#{e.class.name}: #{e}")
      fail! invalid_message
    end
  end
end
