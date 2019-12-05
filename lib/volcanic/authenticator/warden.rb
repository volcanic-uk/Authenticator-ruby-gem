# frozen_string_literal: true

require 'warden'
require_relative 'warden/auth_failure'
require_relative 'warden/allow_always'
require_relative 'warden/validate_token_always'
require_relative 'warden/validate_token_present'

module Volcanic::Authenticator
  # this class provide strategies and fail response handler
  # strategies:
  #   +AllowAlways+ allow request whether authorization exist or not
  #   +ValidateTokenAlways+ forbid request if authorization is not exist or invalid
  #   +ValidateTokenPresent+ forbid request when authorization header exist and invalid, if not exist request is allow
  module Warden; end
end
