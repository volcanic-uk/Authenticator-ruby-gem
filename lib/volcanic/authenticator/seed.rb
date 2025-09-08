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
      @roles ||= IndexedCollection.new(:id, :name)
    end

    def service
      @service ||= V1::Service.find_by_id(service_name)
    end

    def permissions
      @permissions ||= begin
        permissions = IndexedCollection.new(:id, :name)
        permissions.concat Volcanic::Authenticator::V1::Permission.find(all: true, service_id: service.id)
      end
    end

    def privileges
      @privileges ||= begin
        privs = IndexedCollection.new(:id, :permission_id, :group_id, :scope)
        privs.concat Volcanic::Authenticator::V1::Privilege.find(all: true)
      end
    end

    def permission_groups
      @permission_groups ||= begin
        groups = IndexedCollection.new(:id, :name)
        groups.concat Volcanic::Authenticator::V1::PermissionGroup.find(all: true)
      end
    end

    def role_by_name(name)
      roles.by_name(name).first ||
        roles.concat(Volcanic::Authenticator::V1::Role.find(name: name)).by_name(name).first
    end

    def role_by_id(id)
      roles.by_id(id).first ||
        roles.concat(Volcanic::Authenticator::V1::Role.find_by_id(id)).by_id(id).first
    end

    # roles should be hashes with name, parent id and privilege IDs
    # if the role already exists, the privilege ids will be updated to
    # add any missing in. Unspecified privileges will not be removed.
    # rubocop:disable Metrics/AbcSize
    def create_roles(*desired)
      desired.flatten.map do |role|
        existing_role = role_by_name(role[:name])
        if existing_role.nil?
          logger.info "Creating role #{role[:name]}"
          roles.add Volcanic::Authenticator::V1::Role.create(role[:name],
                                                             privilege_ids: role[:privilege_ids],
                                                             parent_id: role[:parent_id])
        else
          (role[:privilege_ids] - existing_role.privilege_ids).each do |id|
            logger.info "Adding privilege #{id} to role #{existing_role.name}"
            existing_role.add_privilege(id)
          end
          existing_role.save
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    # groups should be strings - the group name
    def create_permission_groups(*groups)
      groups.flatten.map do |grp|
        next unless permission_groups.by_name(grp).empty?

        logger.info "Creating permission #{grp}"
        permission_groups.add Volcanic::Authenticator::V1::PermissionGroup.create(name: grp)
      end.compact
    end

    # permissions should be strings - the permission name
    def create_permissions(*perms)
      perms.flatten.map do |perm|
        next unless permissions.by_name(perm).empty?

        logger.info "Creating permission #{perm}"
        permissions.add Volcanic::Authenticator::V1::Permission.create(service_id: service.id,
                                                                       name: perm)
      end.compact
    end

    # privs should be hashes with keys of perm: permission_name, group: group_name,
    # allow: boolean, scope: vrn
    def create_privileges(*privs)
      privs.flatten.map { |desired| create_privilege(**desired) }
    end

    private

    attr_reader :roles

    def create_privilege(scope:, group: nil, perm: nil, allow: nil)
      allow = allow.nil? ? true : allow

      if group
        privileges.add create_privilege_for_group(group, allow, scope)
      else
        privileges.add create_privilege_for_permission(perm, allow, scope)
      end
    end

    def create_privilege_for_permission(perm_name, allow, scope)
      create_permissions perm_name
      perm = permissions.by_name(perm_name).first

      existing = privileges.by_permission_id(perm.id).find \
        { |priv| priv.scope == scope && priv.allow == allow }

      existing || begin
        logger.info "Creating privilege to #{allow ? 'allow' : 'deny'} on '#{perm_name}' for #{scope}"
        Volcanic::Authenticator::V1::Privilege.create(permission_id: perm.id, allow: allow, scope: scope)
      end
    end

    def create_privilege_for_group(group_name, allow, scope)
      create_permission_groups group_name
      group = permission_groups.by_name(group_name).first

      existing = privileges.by_group_id(group.id).any? \
        { |priv| priv.scope == scope && priv.allow == allow }

      existing || begin
        logger.info "Creating privilege to #{allow ? 'allow' : 'deny'} on '#{group_name}' for #{scope}"
        Volcanic::Authenticator::V1::Privilege.create(group_id: group.id, allow: allow, scope: scope)
      end
    end
  end
end
