# frozen_string_literal: true

require_relative 'strategy_helper'

module Volcanic::Authenticator
  module V1::Warden
    # this strategy allow all request
    class AllowAlways < Warden::Strategies::Base
      def authenticate!
        success! ''
      end
    end
  end
end
