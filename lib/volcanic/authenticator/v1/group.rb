# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    #
    # Handle permission group api
    class Group
      include Request
      include Error
      # end-point
      GROUP_URL = 'api/v1/groups'

      attr_accessor :id, :name, :description
      attr_reader :subject_id
      #
      # initialize new group
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @description = opt[:description]
        @subject_id = opt[:subject_id]
        @active = opt[:active]
      end

      #
      # to check activation
      #
      # eg.
      #   group = Group.find_by_id(1)
      #   group.active? # => true
      #
      def active?
        @active == 1
      end

      #
      # to update a group
      #  eg.
      #   group = Group.find_by_id(1)
      #   group.name = 'new group name'
      #   group.description = 'new group description'
      #   group.save
      #
      def save
        payload = { name: name, description: description }
        payload.delete_if { |_, value| value.nil? }
        res = perform_post_request "#{GROUP_URL}/#{id}", payload.to_json
        raise_exception_group res unless res.success?
      end

      #
      # to delete a group
      #  eg.
      #  Group.find_by_id(1).delete
      #
      #  or
      #
      #  Group.new(id: 1).delete
      #
      def delete
        res = perform_delete_request "#{GROUP_URL}/#{id}"
        raise_exception_group res unless res.success?
      end

      class << self
        include Request
        include Error
        #
        # to Create a new group
        #
        # eg.
        #  group = Group.create(group_name, descriptions, permissions_ids)
        #  group.name # => 'group-a'
        #  group.id # => 1
        #  ...
        #
        #
        def create(name, description = nil, *permissions)
          payload = { name: name,
                      description: description,
                      permissions: permissions.flatten.compact }.to_json
          res = perform_post_request GROUP_URL, payload
          raise_exception_group res unless res.success?
          parsed = JSON.parse(res.body)['response']
          new(parsed.transform_keys!(&:to_sym))
        end

        #
        # to request an array of Grou[s].
        #
        # eg.
        #   groups = Group.find
        #   groups[1].name # => 'group-a'
        #   groups[1].id # => 1
        #   ...
        #
        def find(page: 1, page_size: 10, key_name: '')
          params = %W[page=#{page} page_size=#{page_size} query=#{key_name}]
          url = "#{GROUP_URL}?#{params.join('&')}"
          res = perform_get_request url
          raise_exception_group res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser['data'].map do |data|
            new(data.transform_keys!(&:to_sym))
          end
        end

        #
        # to find by given id
        #
        # eg.
        #   group = Group.find_by_id(group_id)
        #   group.name # => 'group-a'
        #   group.id # => 1
        #   ....
        #
        def find_by_id(id)
          raise ArgumentError, 'argument is empty or nil' if id.nil? || id == ''

          res = perform_get_request "#{GROUP_URL}/#{id}"
          raise_exception_group res unless res.success?
          parsed = JSON.parse(res.body)['response']
          new(parsed.transform_keys!(&:to_sym))
        end
      end
    end
  end
end
