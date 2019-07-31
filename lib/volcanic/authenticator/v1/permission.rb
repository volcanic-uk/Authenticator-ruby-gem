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
      attr_reader :id, :subject_id, :service_id, :created_at, :updated_at
      #
      # initialize permission
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @description = opt[:description]
        @subject_id = opt[:subject_id]
        @service_id = opt[:service_id]
        @active = opt[:active]
        @created_at = opt[:created_at]
        @updated_at = opt[:updated_at]
      end

      #
      # to check for permission activation
      # eg.
      #   permission = Permission.find(1)
      #   permission.active? # => true
      #
      def active?
        @active.nil? ? Permission.find(id).active? : @active
      end

      #
      # to update a permission
      # eg.
      #   permission = Permission.find(1)
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
      #  Permission.new(id: 1).delete
      #
      # or
      #
      #  Permission.find(1).delete
      #
      def delete
        perform_delete_and_parse EXCEPTION, "#{PERMISSION_URL}/#{id}"
      end

      class << self
        include Request
        include Error
        #
        # to _create a new permission.
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
        # find permission or permissions
        #
        def find(id = nil, **opts)
          if id.nil?
            opts[:page] ||= 1
            opts[:page_size] ||= 10
            find_with(opts)
          else
            find_by_id(id)
          end
        end

        #
        # get first object
        #
        def first
          find(page_size: 1)[0]
        end

        #
        # get last object
        #
        def last
          find(page: count, page_size: 1)[0]
        end

        #
        # get total count
        #
        def count
          find(page_size: 1, pagination: true)[:pagination][:rowCount]
        end

        private

        def find_with(pagination: false, **opts)
          params = opts.map { |k, v| "#{k}=#{v}" }.join('&')
          url = "#{PERMISSION_URL}?#{params}"
          parsed = perform_get_and_parse EXCEPTION, url
          data = parsed['data'].map { |d| new(d.transform_keys(&:to_sym)) }
          if pagination
            { pagination: parsed['pagination'].transform_keys(&:to_sym),
              data: data }
          else
            data
          end
        end

        #
        # to find permission by given id
        #
        #
        def find_by_id(id)
          raise ArgumentError, 'id is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse EXCEPTION, "#{PERMISSION_URL}/#{id}"
          new(parsed.transform_keys(&:to_sym))
        end
      end
    end
  end
end
