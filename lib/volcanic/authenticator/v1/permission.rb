# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    #
    # Handle permission api
    class Permission
      include Request
      include Error
      # end-point
      PERMISSION_URL = 'api/v1/permissions'
      EXCEPTION = :raise_exception_permission

      attr_accessor :name, :description
      attr_reader :id, :subject_id, :service_id
      #
      # initialize permission
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @description = opt[:description]
        @subject_id = opt[:subject_id]
        @service_id = opt[:service_id]
        @active = opt[:active]
      end

      #
      # to check for permission activation
      # eg.
      #   permission = Permission.find_by_id(1)
      #   permission.active? # => true
      #
      def active?
        @active == 1
      end

      #
      # to update a permission
      # eg.
      #   permission = Permission.find_by_id(1)
      #   permission.name = 'new permission name'
      #   permission.description = 'new permission description'
      #   permission.save
      #
      def save
        payload = { name: name, description: description }.to_json
        perform_post_and_parse EXCEPTION, "#{PERMISSION_URL}/#{id}", payload
      end

      #
      # to delete a permission
      # eg.
      #  Permission.new(1).delete
      #
      # or
      #
      #  Permission.find_by_id(1).delete
      #
      def delete
        perform_delete_and_parse EXCEPTION, "#{PERMISSION_URL}/#{id}"
      end

      class << self
        include Request
        include Error
        #
        # to Create a new permission.
        #
        # eg.
        #  permission = Permission.create(permission_name, service_id, descriptions)
        #  permission.name # => 'permission-a'
        #  permission.id # => 1
        #  permission.creator_id # => 1
        #  ...
        #
        def create(name, service_id, description = nil)
          payload = { name: name,
                      description: description,
                      service_id: service_id }.to_json
          parsed = perform_post_and_parse EXCEPTION, PERMISSION_URL, payload
          new(parsed.transform_keys(&:to_sym))
        end

        #
        # to receive an array of permissions.
        #
        # eg.
        #   permissions = Permission.find()
        #   permissions[0].name # => 'permission-a'
        #   permissions[0].id # => 1
        #   ...
        #
        def find(page: 1, page_size: 10, key_name: '')
          params = %W[page=#{page} page_size=#{page_size} query=#{key_name}].join('&')
          url = "#{PERMISSION_URL}?#{params}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map do |data|
            new(data.transform_keys(&:to_sym))
          end
        end

        #
        # to find permission by given id
        #
        # eg.
        #   permission = Permission.find_by_id(1)
        #   permission.name # => 'permission-a'
        #   permission.id # => 1
        #
        def find_by_id(id)
          raise ArgumentError, 'argument is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse EXCEPTION, "#{PERMISSION_URL}/#{id}"
          new(parsed.transform_keys(&:to_sym))
        end
      end
    end
  end
end
