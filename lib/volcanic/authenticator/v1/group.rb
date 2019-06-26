require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    #
    # Handle permission group api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :id, :permissions, :creator_id, :active
    class Group
      # end-point
      GROUP_URL = 'api/v1/group'
      GROUP_UPDATE_URL = 'api/v1/group/update'
      GROUP_DELETE_URL = 'api/v1/group/delete'

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
        #
        # to Create a new group
        #
        # eg.
        #  group = Group.create(group_name, permissions_ids, descriptions)
        #  group.name # => 'group-a'
        #  group.id # => '<GROUP_ID>'
        #  ...
        #
        #  note: permission_ids must be in array of permission id. eg. [1,2]
        def create(name, permissions = [], description = nil)
          payload = { name: name,
                      description: description,
                      permissions: permissions }.to_json
          res = perform_post_request GROUP_URL, payload
          raise_exception_group res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['id'], parser['creator_id'], parser['description'])
        end
        #
        # to receive an array of groups
        #
        # eg.
        #   groups = Group.all
        #   groups[0].name # => 'group-a'
        #   groups[0].id # => '<GROUP_ID>'
        #   ....
        #
        def all(sort = 10)
          res = perform_get_request "#{GROUP_URL}/all"
          raise_exception_group res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser.map do |group|
            new(group['name'],
                group['id'],
                group['creator_id'],
                group['description'],
                group['active'])
          end
        end
        #
        # to find by given id
        #
        # eg.
        #   group = Group.find_by_id(group_id)
        #   group.name # => 'group-a'
        #   group.id # => '<GROUP_ID>'
        #   ....
        #
        def find_by_id(id)
          res = perform_get_request "#{GROUP_URL}/#{id}"
          raise_exception_group res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'],
              parser['id'],
              parser['creator_id'],
              parser['description'],
              parser['active'])
        end
        #
        # to update a group
        #  Eg.
        #  attributes = { name: 'group-b',  permissions: [3,4] } # must be in hash value
        #  Group.update(group_id, attributes)
        #
        def update(id, attr)
          raise GroupError, 'Attributes must be a hash type' unless attr.is_a?(Hash)

          payload = attr.to_json
          res = perform_post_request "#{GROUP_UPDATE_URL}/#{id}", payload
          raise_exception_group res unless res.success?
        end
        #
        # to delete a group
        #  Eg.
        #  Group.delete(group_id)
        #
        def delete(id)
          res = perform_post_request "#{GROUP_DELETE_URL}/#{id}"
          raise_exception_group res unless res.success?
        end
      end
    end
  end
end