# frozen_string_literal: true

require_relative 'v1/config'
require_relative 'v1/exception'

require_relative 'v1/http_request'
require_relative 'v1/resource.rb'
require_relative 'v1/warden/allow_always'
require_relative 'v1/warden/validate_token_always'
require_relative 'v1/warden/validate_token_present'

require_relative 'v1/principal.rb'
require_relative 'v1/identity.rb'
require_relative 'v1/token.rb'
require_relative 'v1/service.rb'

require_relative 'v1/helper/app_token'
require_relative 'v1/helper/key'

# gem base
module Volcanic::Authenticator
  def self.config
    yield Volcanic::Authenticator::V1::Config if block_given?
    Volcanic::Authenticator::V1::Config
  end
end
