require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle permission api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :id, :creator_id, :description, :active
    class Permission
      attr_reader :name, :id, :creator_id, :description, :active
      ##
      # initialize new permission
      # attr :name, :id, :creator_id, :description, :active
      def initialize(name = nil, id = nil, creator_id = nil, description = nil, active = nil)
        @name = name
        @id = id
        @creator_id = creator_id
        @description = description
        @active = active
      end

      class << self
        include Request
        include Error
        ##
        # Create new permission
        # Eg.
        #  permission = Permission.create('permissionA', 1)
        #  permission.name # => 'permissionA'
        #  permission.id # => '<GENERATED_ID>'
        #  permission.creator_id # => 1
        #  permission.description # => ''
        #  permission.active # => nil
        #
        def create(name, creator_id = nil, description = nil)
          payload = { name: name,
                      creator_id: creator_id,
                      description: description }.to_json
          res = perform_post_request PERMISSION, payload
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['id'], parser['creator_id'], parser['description'])
        end

        ##
        # Retrieve/read permission (all)
        #  Eg.
        #  Permission.retrieve
        #  # => return an array pf permission
        #
        # Retrieve/read permission (by id)
        #  Eg.
        #  permission = Permission.retrieve(1)
        #  permission.name # => 'permissionA'
        #  permission.id # => 1
        #  permission.creator_id # => 1
        #  permission.description # => ''
        #  permission.active # => 1
        #
        def retrieve(id = 'all')
          res = perform_get_request "#{PERMISSION}/#{id}"
          raise_exception_permission res unless res.success?
          parser = JSON.parse(res.body)['response']
          return parser if id == 'all'

          new(parser['name'],
              parser['id'],
              parser['creator_id'],
              parser['description'],
              parser['active'])
        end

        ##
        # Update permission
        #  Eg.
        #  attr = { name: 'newPermissionName' }
        #  Permission.update(1, attr)
        #
        def update(id, attributes)
          raise PermissionError, 'Attributes must be a hash type' unless attributes.is_a?(Hash)

          payload = attributes.to_json
          res = perform_post_request "#{PERMISSION_UPDATE}/#{id}", payload
          raise_exception_permission res unless res.success?
        end

        ##
        # Delete permission
        #  Eg.
        #  Permission.delete(1)
        #
        def delete(id)
          res = perform_post_request "#{PERMISSION_DELETE}/#{id}"
          raise_exception_permission res unless res.success?
        end
      end
    end
  end
end
