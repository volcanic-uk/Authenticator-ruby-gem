# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class PermissionGroup < Common
      class << self
        def path
          'api/v1/groups'
        end

        def exception
          PermissionGroupError
        end
      end

      def initialize(name:, active:, **args)
        @id = args.fetch(:id, nil)
        @name = name
        @active = active
        %i[description subject_id created_at updated_at].each do |arg|
          send("#{arg}=", args.fetch(arg, ''))
        end
      end

      def permission_ids
        @permission_ids ||= []
      end

      attr_accessor :id, :name, :description, :subject_id, :active, :created_at, :updated_at
    end
  end
end