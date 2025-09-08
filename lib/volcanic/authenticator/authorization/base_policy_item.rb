# frozen_string_literal: true

require_relative 'policy_item_registry'

module Volcanic::Authenticator::Authorization
  # BasePolicyItem provides an implementation of the key methods that can be used by
  # policy items to help make authorisation decisions
  class BasePolicyItem
    class << self
      attr_accessor :permission_name, :service_name

      def inherited(child_policy_item)
        PolicyItemRegistry.lazy_register(child_policy_item)

        super
      end
    end

    attr_reader :current_user, :target

    # this will be provided with a CurrentUser object representing the user
    # which may provide a vault user, may be a superadmin, or may be an API
    # "user".
    def initialize(current_user, target)
      @target = target
      @current_user = current_user
    end

    def authorized?
      privs = qualified_privileges
      # disabling rubocop false-positive
      # rubocop:disable Style/EmptyElse
      if privs.blank?
        false
      else
        allowed = privs.map(&:allow).uniq
        if allowed.size == 1
          allowed.first
        else
          nil
        end
      end
      # rubocop:enable Style/EmptyElse
    end

    # Scope is the scope of the request being passed in. It should be added to or removed from prior
    # to the scope being passed on to be resolved by the adapter.
    def scope(scope)
      scope
    end

    # This should be overridden by policies that care about the qualifiers
    # It will be called with a hash of qualifiers for every valid privilege
    # and needs to be fast (i.e. not call to Vault each time)
    #
    # It should return true if the qualifiers are all valid in the current
    # context or false if they are not.
    def qualifiers_valid?(_qualifiers)
      true
    end

    def target_vrn
      if target.respond_to?(:vrn)
        target.vrn
      else
        VRN.parse(target)
      end
    end

    def permission_name
      self.class.permission_name
    end

    def service_name
      self.class.ancestors.find do |cls|
        cls.send(:service_name) if cls.respond_to?(:service_name)
      end&.service_name
    end

    # Obtain all of the relevant privileges for this service and permision
    # This is useful when generating scopes
    def privileges
      if current_user.nil?
        []
      else
        UserPrivilegeCache.privileges_for(current_user.urn, service_name, permission_name)
      end
    end

    # Obtain only those privileges which are relevant to the requested target
    def qualified_privileges
      @qualified_privileges ||= begin
        vrn_string = target_vrn.to_s
        privileges.dup.delete_if do |priv|
          !priv.scope.include?(vrn_string) { |qualifiers| qualifiers_valid?(**qualifiers) }
        end.sort
      end
    end
  end
end
