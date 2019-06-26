# frozen_string_literal: true

require_relative 'v1/exception'

require_relative 'v1/http_request'
require_relative 'v1/active_resource.rb'

require_relative 'v1/principal.rb'
require_relative 'v1/identity.rb'
require_relative 'v1/token.rb'
require_relative 'v1/service.rb'
require_relative 'v1/privilege.rb'
require_relative 'v1/permission.rb'
require_relative 'v1/group_permission.rb'

require_relative 'v1/helper/app_token'
require_relative 'v1/helper/key'

# contain v1 classes
module Volcanic::Authenticator
  # v1 module
  module V1; end
end
