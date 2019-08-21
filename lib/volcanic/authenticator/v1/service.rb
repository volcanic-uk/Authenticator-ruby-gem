# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Handle service api
    class Service < Common
      include Request
      include Error
      # end-point
      URL = 'api/v1/services'
      EXCEPTION = :raise_exception_service

      attr_accessor :name
      attr_reader :id, :subject_id, :updated_at, :created_at

      # initialize new service
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @subject_id = opt[:subject_id]
        @active = opt[:active]
        @created_at = opt[:created_at]
        @updated_at = opt[:updated_at]
      end

      # service.name = 'update_name'
      # service.save
      def save
        super({ name: name })
      end

      # service = Service.create('vault')
      # service.name # => vault
      # service.id # => 1
      # ...
      def self.create(name)
        super({ name: name })
      end
    end
  end
end
