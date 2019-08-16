# frozen_string_literal: true

require 'forwardable'

module Volcanic::Authenticator
  module V1
    ##
    # Base class
    # Contains of Volcanic::Cache::Cache and
    # Volcanic::Authenticator.config forwardable.
    class Base
      extend SingleForwardable
      def_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_app_token, :exp_public_key, :app_name, :app_secret, :app_principal_id
    end
  end
end
