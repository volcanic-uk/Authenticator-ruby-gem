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
      def_single_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_single_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_app_token, :exp_public_key, :app_name, :app_secret, :app_dataset_id, :service_name, :auth_enabled?

      extend Forwardable
      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :auth_url, :service_name, :exp_authorize_token
    end
  end
end
