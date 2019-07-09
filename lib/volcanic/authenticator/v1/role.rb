# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    #
    # Handle role api
    class Role
      include Request
      include Error
      # end-point
      ROLE_URL = 'api/v1/roles'
      EXCEPTION = :raise_exception_role

      attr_accessor :id, :name, :service_id
      attr_reader :subject_id, :privileges
      #
      # initialize new role
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @subject_id = opt[:subject_id]
        @service_id = opt[:service_id]
        @privileges = opt[:privileges]
      end

      def privileges=(*ids)
        @privileges = ids.flatten.compact
      end

      #
      # to update a role.
      #
      # eg.
      #   role = Role.find_by_id(1)
      #   role.name = 'new-role-name'
      #   role.save
      #
      def save
        payload = { name: name, service_id: service_id, privileges: privileges }.to_json
        perform_post_and_parse EXCEPTION, "#{ROLE_URL}/#{id}", payload
      end

      #
      # to delete role
      #
      # eg.
      #   role = Role.find_by_id(1)
      #   role.delete
      #
      #   OR
      #
      #   Role.new(2).delete
      #
      def delete
        perform_delete_and_parse EXCEPTION, "#{ROLE_URL}/#{id}"
      end

      class << self
        include Request
        include Error
        ##
        # Create new role
        # Eg.
        #  role = Role.create('role-a')
        #  role.name # => 'role-a'
        #  role.id # => 1
        #
        def create(name, service_id, *privileges)
          payload = { name: name,
                      service_id: service_id,
                      privileges: privileges.flatten.compact }.to_json
          parsed = perform_post_and_parse EXCEPTION, ROLE_URL, payload
          new(parsed.transform_keys!(&:to_sym))
        end

        #
        # to request an array of roles.
        #
        # eg.
        #   roles = Role.find
        #   roles[1].name # => 'role-a'
        #   roles[1].id # => 1
        #   ...
        #
        def find(key_name: '', page: 1, page_size: 10)
          params = %W[page=#{page} page_size=#{page_size} query=#{key_name}]
          url = "#{ROLE_URL}?#{params.join('&')}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map do |data|
            new(data.transform_keys!(&:to_sym))
          end
        end

        #
        # to request a role by given id.
        #
        # eg.
        #   role = Role.find_by_id(role_id)
        #   role.name # => 'role-a'
        #   role.id # => 1
        #   ...
        #
        def find_by_id(id)
          raise ArgumentError, 'argument is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse EXCEPTION, "#{ROLE_URL}/#{id}"
          new(parsed.transform_keys!(&:to_sym))
        end
      end
    end
  end
end
