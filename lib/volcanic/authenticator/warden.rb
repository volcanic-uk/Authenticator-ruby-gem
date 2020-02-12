# frozen_string_literal: true

require_relative 'warden/allow_always'
require_relative 'warden/validate_token'
require_relative 'warden/validate_token_present'
require_relative 'warden/validate_session_token'
require_relative 'warden/volcanic_omniauth'

module Volcanic::Authenticator
  # this class provide strategies and failure_app
  # strategies:
  #   +AllowAlways+ allow request whether authorization exist or not
  #   +ValidateToken+ forbid request if authorization header is invalid
  #   +ValidateTokenPresent+ forbid request if authorization header is exist and invalid, if not exist request is pass
  #   +ValidateSession+ forbid request if session[:auth_token] is invalid
  #   +ValidateSessionPresent+ forbid request if session[:auth_token] is exist and invalid, if not exist request is pass
  #
  module Warden; end
end
