require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    #
    # Handle permission api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :id, :creator_id, :description, :active
    class Permission
      # end-point
      PERMISSION_URL = 'api/v1/permission'
      PERMISSION_UPDATE_URL = 'api/v1/permission/update'
      PERMISSION_DELETE_URL = 'api/v1/permission/delete'

      attr_reader :name, :id, :creator_id, :description, :active
      #
      # initialize permission
      def initialize(name = nil, id = nil, creator_id = nil, description = nil, active = false)
        @name = name
        @id = id
        @creator_id = creator_id
        @description = description
        @active = active == '1' ? true : false
      end

      class << self
        include Request
        include Error
        #
        # to Create a new permission.
        #
        # eg.
        #  permission = Permission.create(permission_name, descriptions)
        #  permission.name # => 'permission-a'
        #  permission.id # => '<permission_id>'
        #  permission.creator_id # => 1
        #  ...
        #
        def create(name, description = nil)
          payload = { name: name, description: description }.to_json
          res = perform_post_request PERMISSION_URL, payload
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['id'], parser['creator_id'], parser['description'])
        end
        #
        # to receive an array of permissions.
        #
        # eg.
        #   permissions = Permission.all
        #   permissions[0].name # => 'permission-a'
        #   permissions[0].id # => '<permission_id>'
        #   ...
        #
        def all(sort = 10)
          res = perform_get_request "#{PERMISSION_URL}/all"
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser.map do |permission|
            new(permission['name'],
                permission['id'],
                permission['creator_id'],
                permission['description'],
                permission['active'])
          end
        end
        #
        # to find permission by given id
        #
        # eg.
        #   permission = Permission.find_by_id(permission_id)
        #   permission.name # => 'permission-a'
        #   permission.id # => '<permission_id>'
        #
        def find_by_id(id)
          res = perform_get_request "#{PERMISSION_URL}/#{id}"
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'],
              parser['id'],
              parser['creator_id'],
              parser['description'],
              parser['active'])
        end
        #
        # to update a permission
        # eg.
        #  attr = { name: 'newPermissionName' } # must be in hash value
        #  Permission.update(1, attr)
        #
        def update(id, attributes)
          raise PermissionError, 'Attributes must be a hash type' unless attributes.is_a?(Hash)

          payload = attributes.to_json
          res = perform_post_request "#{PERMISSION_UPDATE_URL}/#{id}", payload
          raise_exception_permission res unless res.success?
        end
        #
        # to delete a permission
        # eg.
        #  Permission.delete(1)
        #
        def delete(id)
          res = perform_post_request "#{PERMISSION_DELETE_URL}/#{id}"
          raise_exception_permission res unless res.success?
        end
      end
    end
  end
end
