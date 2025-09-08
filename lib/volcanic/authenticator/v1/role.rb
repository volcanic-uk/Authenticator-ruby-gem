# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Role API
    class Role < Common
      attr_reader :id, :parent_id, :created_at, :updated_at, :name
      attr_writer :cache

      def self.path
        'api/v1/roles'
      end

      def self.exception
        RoleError
      end

      # initialize new role
      def initialize(id:, cache: nil, **opts)
        @id = id
        %i[name parent_id created_at updated_at privilege_ids].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
        parse_privileges(opts[:privileges])
        @dirty = Hash.new { |h, k| h[k] = false }
        @cache = cache || Volcanic::Cache::Cache.new
        @privilege_ids ||= []
      end

      def save
        opts = {}
        dirty.each do |key, value|
          if value
            opts[key] = send(key)
            dirty[key] = false
          end
        end
        opts[:privileges] = opts.delete(:privilege_ids) if opts.key?(:privilege_ids)
        opts[:name] = name
        super(**opts) unless opts.empty?
      end

      def privileges
        @privileges ||= privilege_ids.map do |priv_id|
          cache.fetch("privilege_#{priv_id}") { Privilege.find_by_id(priv_id) }
        end.freeze
      end

      def name=(value)
        dirty[:name] = true
        @name = value
      end

      def privilege_ids=(value)
        dirty[:privilege_ids] = true
        @privileges = nil
        @privlege_ids = value.frozen? ? value : value.dup.freeze
      end

      def privilege_ids
        @privilege_ids.freeze
      end

      def add_privilege(value)
        dirty[:privilege_ids] = true
        @privileges = nil
        @privilege_ids = @privilege_ids.dup
        @privilege_ids << if value.is_a?(Privilege)
                            value.id
                          else
                            value
                          end
      end

      def dirty?
        dirty.values.all?
      end

      class << self
        def create(name, privilege_ids: [], parent_id: nil)
          super({ name: name, privileges: privilege_ids, parent_role_id: parent_id })
        end
      end

      private

      attr_reader :dirty, :cache

      def parse_privileges(privs)
        case privs&.first
        when Integer
          @privilege_ids = privs
        when Hash
          @privilege_ids = privs.map { |priv| priv['id'] }
        when Privilege
          @privilege_ids = privs.map(&:id)
        end
      end
    end
  end
end
