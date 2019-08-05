# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Privileges api
    class Privilege < Common
      URL = 'api/v1/privileges'
      EXCEPTION = :raise_exception_privilege

      attr_accessor :scope, :permission_id, :group_id, :allow
      attr_reader :id, :subject_id, :created_at, :updated_at

      undef_method :active? # remove active?

      # initialize new privilege
      def initialize(id:, **opts)
        @id = id
        @scope = opts[:scope]
        @permission_id = opts[:permission_id]
        @group_id = opts[:group_id]
        @subject_id = opts[:subject_id]
        @allow = opts[:allow]
      end

      # to check privilege allow status
      # eg.
      #
      #   privilege.allow?
      #   # => true/false
      def allow?
        allow.nil? ? find(id).allow? : allow
      end

      # to allow privilege
      def allow!
        return if allow?

        @tmp_allow = true
        save
      end

      # to disallow privilege
      def disallow!
        return unless allow?

        @tmp_allow = false
        save
      end

      # updating privilege
      # eg.
      #   privilege = Privilege.find(1)
      #   privilege.scope = 'update scope'
      #   privilege.save
      #
      def save
        payload = { scope: scope,
                    permission_id: permission_id,
                    group_id: group_id,
                    allow: @tmp_allow || allow }
        @tmp_allow = nil
        super(payload)
      end

      # creating new privilege
      # eg.
      #   privilege = Privilege.create('vrn:eu-2:5:jobs/*', 1, 1, true)
      #   privilege.scope # => 'vrn:eu-2:5:jobs/*'
      #   privilege.permission_id # => 1
      #   privilege.allow? # = true
      #   ...
      def self.create(scope, permission_id, group_id = nil, allow = true)
        raise ArgumentError, 'allow must be in boolean' unless [true, false].include? allow

        payload = { scope: scope,
                    permission_id: permission_id,
                    group_id: group_id,
                    allow: allow }
        super payload
      end
    end
  end
end
