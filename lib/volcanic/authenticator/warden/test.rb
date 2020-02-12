# frozen_string_literal: true

require 'warden'

module Volcanic::Authenticator::Warden
  # this strategy validate token always.
  # if authorization header not present or missing, it fail the request
  class Test < Warden::Strategies::Base
    include StrategyHelper

    def authenticate!
      return fail! 'This is a test strategy.  DO NOT USE IN PRODUCTION' if Rails.env.production?
      return fail! missing_message unless token_exist?
      return fail! invalid_message unless fetch_token == 'test'
      success! 'test'
    end
  end
end
