require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle permission group api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :id, :permissions, :creator_id, :active
    class Group
      attr_reader :name, :id, :creator_id, :description, :active
      ##
      # initialize new group
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
        # Create new group
        # Eg.
        #  group = Group.create('group-a', [1,2], 1)
        #  group.name # => 'group-a'
        #  group.id # => '<GENERATED_ID>'
        #  group.description # => 'group descriptions...'
        #  group.creator_id # => 1
        #  group.active # => nil
        #
        def create(name, description = nil, permissions = [])
          payload = { name: name,
                      description: description,
                      permissions: permissions }.to_json
          res = perform_post_request GROUP, payload
          raise_exception_group res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['id'], parser['creator_id'], parser['description'])
        end

        ##
        # Retrieve/read group (all)
        #  Eg.
        #  group.retrieve
        #  # => return an array of group
        #
        # Retrieve/read group (by id)
        #  Eg.
        #  group = Group.retrieve(1)
        #  group.name # => 'group-a'
        #  group.id # => 1
        #  group.creator_id # => 1
        #  group.description # => 'group descriptions...'
        #  group.active # => 1
        #
        def retrieve(id = 'all')
          res = perform_get_request "#{PERMISSION_GROUP}/#{id}"
          raise_exception_group res unless res.success?
          parser = JSON.parse(res.body)['response']
          return parser if id == 'all' # return array of groups

          # return group object
          new(parser['name'],
              parser['id'],
              parser['creator_id'],
              parser['description'],
              parser['active'])
        end

        ##
        # Update group
        #  Eg.
        #  attr = { name: 'group-b',
        #           permissions: [3,4] }
        #  Group.update(1, attr)
        #
        def update(id, attributes)
          raise GroupError, 'Attributes must be a hash type' unless attributes.is_a?(Hash)

          payload = attributes.to_json
          res = perform_post_request "#{GROUP_UPDATE}/#{id}", payload
          raise_exception_group res unless res.success?
        end

        ##
        # Delete group
        #  Eg.
        #  Group.delete(1)
        #
        def delete(id)
          res = perform_post_request "#{GROUP_DELETE}/#{id}"
          raise_exception_group res unless res.success?
        end
      end
    end
  end
end