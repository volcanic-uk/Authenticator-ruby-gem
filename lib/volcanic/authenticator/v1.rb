# frozen_string_literal: true

require_relative 'v1/exception'

require_relative 'v1/http_request'
require_relative 'v1/active_resource'

require_relative 'v1/principal'
require_relative 'v1/identity'
require_relative 'v1/token'
require_relative 'v1/service'
require_relative 'v1/subject'
require_relative 'v1/permission'
require_relative 'v1/permission_group'
require_relative 'v1/privilege'
require_relative 'v1/role'
require_relative 'v1/scope'

require_relative 'v1/helper/app_token'
require_relative 'v1/helper/key'

# contain v1 classes
module Volcanic::Authenticator
  # v1 module
  module V1; end
end
