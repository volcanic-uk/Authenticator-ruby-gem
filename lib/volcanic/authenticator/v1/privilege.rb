# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class Privilege < Common
      class << self
        def path
          'api/v1/privileges'
        end

        def exception
          PrivilegeError
        end
      end

      def initialize(scope:, permission_id: nil, group_id: nil, allow:, cache: nil, **args)
        @id = args.fetch(:id, nil)
        @scope = Scope.parse(scope)
        @permission_id = permission_id
        @group_id = group_id
        @allow = allow
        @cache = cache || Volcanic::Cache::Cache.new
      end

      def <=>(other)
        if scope == other.scope
          (allow_bool <=> other.allow_bool) * -1
        else
          scope <=> other.scope
        end
      end

      # Compare provided VRN with the scope we have
      # Returns
      # => boolean
      def in_scope?(vrn)
        scope.include?(vrn)
      end

      # Without casting to an integer we get a comparison error when
      # sorting using the spaceship (<=>) operator.
      def allow_bool
        allow == true ? 1 : 0
      end

      def scope=(value)
        @scope = Scope.parse(value)
      end

      attr_accessor :id, :allow
      attr_reader :scope, :permission, :permission_id, :group_id
      attr_writer :cache

      def permission=(value)
        clear_dirty
        @permission_id = value.id
        @permission = value
      end

      def permission_id=(value)
        clear_dirty
        @permission_id = value
      end

      def group_id=(value)
        clear_dirty
        @group_id = value
      end

      def ==(other)
        %i[@id @permission_id @group_id @allow @scope].all? do |field|
          instance_variable_get(field) == other.instance_variable_get(field)
        end
      end

      def group
        return nil unless group_id

        cache.fetch("permission_group_#{group_id}") { PermissionGroup.find_by_id(group_id) }
      end

      def permission_ids
        @permission_ids ||= [permission_id, group&.permission_ids].flatten.compact
      end

      def permissions
        @permissions ||= permission_ids.map do |perm_id|
          cache.fetch("permission_#{perm_id}") { Permission.find_by_id(perm_id) }
        end
      end

      def permission_names
        permissions.map(&:name)
      end

      private

      attr_reader :cache

      def clear_dirty
        @permission = nil
        @permissions = nil
        @permission_ids = nil
      end
    end
  end
end
