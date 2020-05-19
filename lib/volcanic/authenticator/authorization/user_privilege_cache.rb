# frozen_string_literal: true

require 'forwardable'

module Volcanic::Authenticator::Authorization
  # The UserPrivilegeCache provides a single entry point to cached privileges for users.
  # It is expected to normally be used via class methods, which will defer to a singleton
  # instance in memory.
  class UserPrivilegeCache
    # This mutex provided to ensure that the class is thread-safe when creating other
    # singletons. It is only used to provide the initial safe creation (and reset)
    # and should not be relied on to provide thread-safe access to the contents of
    # the singleton (that is the responsibility of the instance, not the class).
    @_singleton_mutex = Mutex.new

    def initialize(permission_expiry: 86_400, privilege_expiry: 300)
      @permission_cache = Volcanic::Cache::Cache.new(default_expiry: permission_expiry)
      @user_service_cache = Volcanic::Cache::Cache.new(default_expiry: privilege_expiry, max_size: 10_000)
    end

    # obtain an array of privileges that are valid for a given urn, service and permission
    def privileges_for(urn, service, permission_name)
      urn = urn.to_s # handle when a urn is a URN object
      user_service_cache.fetch("#{urn}_#{service}") do
        privs = Volcanic::Authenticator::V1::Subject.privileges_for(urn, service)

        # inject the permission cache to allow the privileges easier access to the
        # permission names
        privs.each { |priv| priv.cache = permission_cache }
        Volcanic::Authenticator::IndexedCollection.new(:permission_names).concat(privs)
      end.by_permission_names(permission_name)
    end

    def permission_expiry=(value)
      permission_cache.default_expiry = value
    end

    def privilege_expiry=(value)
      user_service_cache.default_expiry = value
    end

    class << self
      extend Forwardable
      def_delegators :instance, :privileges_for, :permission_expiry=, :privilege_expiry=

      def instance
        @_singleton_mutex.synchronize { @_singleton_instance ||= new }
      end

      # this is provided to support resetting the singleton for testing purposes
      # it should not be used in a production setting
      def _reset_instance
        @_singleton_mutex.synchronize { @_singleton_instance = nil }
      end
    end

    private

    attr_reader :permission_cache, :user_service_cache
  end
end
