# frozen_string_literal: true

require_relative 'helper/request'
require_relative 'helper/error'
require_relative 'helper/collection'

module Volcanic::Authenticator
  module V1
    # This is a common class where it contains all the common methods
    # for all the features in auth service. For now this class support for:
    # Identity, Principal, Service, Permission, GroupPermission, Role and Privileges
    class Common
      include Request

      def self.path
        raise NotImplementedError, 'self.path must be defined by child classes'
      end

      def self.exception
        raise NotImplementedError, 'self.exception must be defined by child classes'
      end

      def id
        raise NotImplementedError, 'id must be defined by child classes'
      end

      # saving updated fields.
      # eg.
      #   obj = Obj.find_by_id(1)
      #   obj.name = 'new name'
      #   obj.save
      def save(**payload)
        payload.delete_if { |_, value| value.nil? }
        perform_post_and_parse self.class.exception, "#{self.class.path}/#{id}", payload.to_json
      end

      # deleting object
      # eg.
      #   Obj.find_by_id(1).delete
      def delete
        perform_delete_and_parse self.class.exception, "#{self.class.path}/#{id}"
      end

      class << self
        include Request
        include Error

        # creating new object
        # eg.
        #   obj = Obj.create(name, description, ...)
        #   obj.name
        #   obj.description
        #   ...
        def create(payload)
          parsed = perform_post_and_parse exception, path, payload.to_json
          new(parsed.transform_keys(&:to_sym))
        end

        # search or find objects
        # eg.
        #   1) finding single object
        #
        #   obj = Obj.find_by_id(1)
        #   obj.name
        #   obj.descriptions
        #   ....
        #
        #   2) finding multiple objects
        #
        #   # by page, page_size, query, sort, order, pagination
        #
        #   Obj.find(page: 1, page_size: 2)
        #   [
        #     <Obj:1>,
        #     <Obj:2>
        #   ]
        #   # return objects (2 count) on the first page.
        #   # Note: by default page: 1 and page_size: 10.
        #
        #   Obj.find(query: 'vol')
        #   [
        #     <Obj:1 @name='volcanic'>,
        #     <Obj:2 @name='volume'>,
        #     ...
        #   ]
        #   # return objects with name contains of 'vol'.
        #
        #   Obj.find(sort: 'id', order: 'desc')
        #   [
        #     <Obj:1 @id=10>,
        #     <Obj:2 @id=9>,
        #     <Obj:3 @id=8>,
        #     ...
        #   ]
        #   # return objects with descending order of id.
        #   # Note: sort must be one of [id, name, created_at, updated_at].
        #   # Note: order must be one of [asc, desc].
        #
        #
        #   # pagination information
        #   # every array of the object will consist of pagination information
        #   # +page+ is current page
        #   # +page_size+ is the size of the data in a page
        #   # +row_count+ is the total count of data
        #   # +page_count+ is the total count of page.
        #
        #   obj = Obj.find
        #   obj = [<Obj:1>, <Obj:2>, ...]
        #   obj.page = 1
        #   obj.page_size = 3
        #   obj.row_count = 1
        #   obj.page_size = 1
        #
        def find(**opts)
          opts[:page] ||= 1
          opts[:page_size] ||= 10
          find_with(opts)
        end

        def find_by_id(id)
          raise ArgumentError, 'id is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse exception, "#{path}/#{id}"
          new(parsed.transform_keys!(&:to_sym))
        end

        private

        def find_with(**opts)
          params = opts.map { |key, val| "#{key}=#{val}" }.join('&') # convert to query string
          url = "#{path}?#{params}"
          parsed = perform_get_and_parse exception, url
          page_information = parsed['pagination'].transform_keys(&:to_sym)
          Collection.from_auth_service(parsed['data'].map { |d| new(d.transform_keys(&:to_sym)) },
                                       page_information) # return as collections (object array)
        end
      end
    end
  end
end
