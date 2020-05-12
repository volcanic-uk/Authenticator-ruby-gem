# frozen_string_literal: true

module Volcanic::Authenticator
  # A lovely little helper class that will allow the discerning user
  # to bulk-create all things auth. This is mostly for seeding data...
  # ... hence the name.
  class Seed
    attr_accessor :service_name, :logger

    def initialize(service_name:)
      @service_name = service_name
      @logger = defined?(Rails.logger) ? Rails.logger : Logger.new(STDOUT)
    end

    def service
      @service ||= V1::Service.find_by_id(service_name)
    end

    def permissions
      @permissions ||= load_permissions
    end

    def privileges
      @privileges ||= load_privileges
    end

    def permission_groups
      @permission_groups ||= load_permission_groups
    end

    def create_permission_groups(*groups)
      groups.flatten.map do |grp|
        next unless permission_groups.by_name(grp).empty?

        logger.info "Creating permission #{grp}"
        permission_groups.add Volcanic::Authenticator::V1::PermissionGroup.create(name: grp)
      end.compact
    end

    def create_permissions(*perms)
      perms.flatten.map do |perm|
        next unless permissions.by_name(perm).empty?

        logger.info "Creating permission #{perm}"
        permissions.add Volcanic::Authenticator::V1::Permission.create(service_id: service.id,
                                                                       name: perm)
      end.compact
    end

    def create_privileges(*privs)
      privs.flatten.map do |desired|
        perm_name = desired[:perm]
        group_name = desired[:group]
        allow = desired[:allow]
        scope = desired[:scope]

        if group_name
          privileges.add create_privilege_for_group(group_name, allow, scope)
        else
          privileges.add create_privilege_for_permission(perm_name, allow, scope)
        end
      end.compact
    end

    private

    def create_privilege_for_permission(perm_name, allow, scope)
      create_permissions perm_name
      perm = permissions.by_name(perm_name).first

      return nil if privileges.by_permission_id(perm.id).any? do |priv|
        priv.scope == scope && priv.allow == allow
      end

      logger.info "Creating privilege to #{allow ? 'allow' : 'deny'} on '#{perm_name}' for #{scope}"
      Volcanic::Authenticator::V1::Privilege.create(permission_id: perm.id, allow: allow, scope: scope)
    end

    def create_privilege_for_group(group_name, allow, scope)
      create_permission_groups group_name
      group = permission_groups.by_name(group_name).first

      return nil if privileges.by_group_id(group.id).any? do |priv|
        priv.scope == scope && priv.allow == allow
      end

      logger.info "Creating privilege to #{allow ? 'allow' : 'deny'} on '#{group_name}' for #{scope}"
      Volcanic::Authenticator::V1::Privilege.create(group_id: group.id, allow: allow, scope: scope)
    end

    def load_permissions
      permissions = IndexedCollection.new(:id, :name)
      page = 1
      until (res = Volcanic::Authenticator::V1::Permission.find(page: page, page_size: 100, service_id: service.id)).empty?
        permissions.concat res
        page += 1
      end
      permissions
    end

    def load_permission_groups
      groups = IndexedCollection.new(:id, :name)
      page = 1
      until (res = Volcanic::Authenticator::V1::PermissionGroup.find(page: page, page_size: 100)).empty?
        groups.concat res
        page += 1
      end
      groups
    end

    def load_privileges
      privs = IndexedCollection.new(:id, :permission_id, :group_id, :scope)
      page = 1
      until (res = Volcanic::Authenticator::V1::Privilege.find(page: page, page_size: 100)).empty?
        privs.concat res
        page += 1
      end
      privs
    end
  end
end
