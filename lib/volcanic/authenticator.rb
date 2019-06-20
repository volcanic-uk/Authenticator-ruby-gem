# frozen_string_literal: true

require 'httparty'
require_relative '../volcanic'
require_relative 'authenticator/v1/config'
require_relative 'authenticator/v1/exception'
require_relative 'authenticator/v1/helper/app_token'
require_relative 'authenticator/v1/helper/key'

module Volcanic
  # Authenticator
  module Authenticator
    # Authenticator base
    module Base
      def config
        Volcanic::Authenticator::V1::Config
      end
    end

    extend Base
  end
end
