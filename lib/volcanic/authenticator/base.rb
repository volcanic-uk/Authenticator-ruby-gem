# frozen_string_literal: true

require_relative 'config'
require_relative 'warden'
require_relative 'v1/exception'

require_relative 'v1/http_request'
require_relative 'v1/resource.rb'

require_relative 'v1/principal.rb'
require_relative 'v1/identity.rb'
require_relative 'v1/token.rb'
require_relative 'v1/service.rb'

require_relative 'v1/helper/app_token'
require_relative 'v1/helper/key'

# gem base
module Volcanic::Authenticator; end
