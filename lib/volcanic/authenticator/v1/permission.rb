# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    #
    # Handle permission api
    # method => :create, :all, :find_by_id, :update, :delete
    # attr => :name, :id, :creator_id, :description, :active
    class Permission
      include Request
      include Error
      # end-point
      PERMISSION_URL = 'api/v1/permissions'

      attr_accessor :name, :description
      attr_reader :id, :subject_id, :service_id
      #
      # initialize permission
      def initialize(id, opt = {})
        @id = id
        @name = opt['name']
        @description = opt['description']
        @subject_id = opt['subject_id']
        @service_id = opt['service_id']
        @active = opt['active']
      end

      #
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
        res = perform_post_request "#{PERMISSION_URL}/#{id}", payload
        raise_exception_permission res unless res.success?
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
        res = perform_delete_request "#{PERMISSION_URL}/#{id}"
        raise_exception_permission res unless res.success?
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
          res = perform_post_request PERMISSION_URL, payload
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['id'], parser)
        end

        #
        # to receive an array of permissions.
        #
        # eg.
        #   permissions = Permission.all
        #   permissions[0].name # => 'permission-a'
        #   permissions[0].id # => 1
        #   ...
        #
        def all(page: 1, page_size: 1, query: '')
          url = "#{PERMISSION_URL}?page=#{page}&page_size=#{page_size}&query=#{query}"
          res = perform_get_request url
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']['data']
          parser.map do |data|
            new(data['id'], data)
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

          res = perform_get_request "#{PERMISSION_URL}/#{id}"
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['id'], parser)
        end
      end
    end
  end
end
