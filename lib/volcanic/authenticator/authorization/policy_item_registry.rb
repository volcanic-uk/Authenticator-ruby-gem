# frozen_string_literal: true

require 'forwardable'

module Volcanic::Authenticator::Authorization
  # The policy item registry allows policy items to be registered and later
  # retrieved.
  class PolicyItemRegistry
    # raise when there is not policy for the requested permission
    class PolicyItemNotFound < RuntimeError
      def initialize(permission_name)
        super("No policy items are available for #{permission_name}")
      end
    end

    # raise when a policy item is registered without a valid permission name
    class PolicyItemInvalid < RuntimeError
      def initialize(policy_item)
        super("Policy item #{policy_item.name} cannot be registered - no permission name")
      end
    end

    def initialize
      @registry = {}
      @pre_reg = []
    end

    def register(policy_item, permission_name = nil)
      permission_name ||= policy_item.permission_name
      raise PolicyItemInvalid, policy_item unless permission_name

      registry[permission_name] = policy_item
    end

    def policy_for(permission_name)
      raise PolicyItemNotFound, permission_name unless key?(permission_name)

      registry[permission_name]
    end

    def key?(permission_name)
      registry.key?(permission_name) || begin
        register(pre_reg.shift) until pre_reg.empty?
        registry.key?(permission_name)
      end
    end

    def lazy_register(policy_item)
      pre_reg.push(policy_item)
    end

    # singleton support:
    @_singleton_mutex = Mutex.new
    class << self
      extend Forwardable
      def_delegators :instance, :register, :policy_for, :lazy_register, :key?

      def instance
        @_singleton_mutex.synchronize { @_singleton_instance ||= new }
      end

      # this is provided to support resetting the singleton for testing purposes
      # it should not be used in a production setting
      def _reset_instance
        _instance = nil
      end

      # this is provided to support injecting the instance for testing purposes
      # it should not be used in a production setting
      def _instance=(value)
        @_singleton_mutex.synchronize { @_singleton_instance = value }
      end
    end

    private

    attr_reader :registry, :pre_reg
  end
end
