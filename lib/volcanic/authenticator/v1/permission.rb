# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class Permission < Common
      class << self
        def path
          'api/v1/permissions'
        end

        def exception
          PermissionError
        end
      end

      def initialize(name:, active: true, **args)
        super()
        @id = args.fetch(:id, nil)
        @name = name
        @active = active
        @privileges = args.fetch(:privileges, [])
        @privilege_ids = args.fetch(:privilege_ids, [])
        %i[description subject_id service_id created_at updated_at].each do |arg|
          send("#{arg}=", args.fetch(arg, ''))
        end
      end

      attr_accessor :id, :name, :description, :subject_id, :service_id, :active,
                    :created_at, :updated_at, :privileges, :privilege_ids
    end
  end
end
