# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Group API
    class Group < Common
      URL = 'api/v1/groups'
      EXCEPTION = :raise_exception_group

      attr_accessor :id, :name, :description
      attr_reader :subject_id, :created_at, :updated_at

      # initialize new group
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @description = opt[:description]
        @subject_id = opt[:subject_id]
        @active = opt[:active]
        @created_at = opt[:created_at]
        @updated_at = opt[:updated_at]
      end

      # updating
      def save
        payload = { name: name, description: description }
        super(payload)
      end

      # creating new
      def self.create(name, description = nil, *permissions)
        payload = { name: name,
                    description: description,
                    permissions: permissions.flatten.compact }
        super(payload)
      end
    end
  end
end
