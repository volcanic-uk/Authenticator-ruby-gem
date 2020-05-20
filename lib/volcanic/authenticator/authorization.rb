# frozen_string_literal: true

module Volcanic::Authenticator
  # Forward module delcaration
  module Authorization; end

  # alias the module to `Z` to allow shortand of
  # Vol::Auth::Z
  Z = Authorization
end

require_relative 'authorization/user_privilege_cache'
require_relative 'authorization/policy_item_registry'
require_relative 'authorization/base_policy_item'
