# frozen_string_literal: true

require 'forwardable'
require_relative 'helper/request'
require_relative 'helper/error'

module Volcanic::Authenticator
  module V1
    # Common method
    class Common
      include Request
      include Error

      # checking activation. Return false if object is deleted
      # eg.
      #   obj = Obj.find(1)
      #   obj.active?
      #   # => true
      def active?
        @active.nil? ? find(@id).active? : @active
      end

      # saving updated fields.
      # eg.
      #   obj = Obj.find(1)
      #   obj.name = 'new name'
      #   obj.save
      def save(payload)
        payload.delete_if { |_, value| value.nil? }
        perform_post_and_parse self.class::EXCEPTION, "#{self.class::URL}/#{id}", payload.to_json
      end

      # deleting object
      # eg.
      #   Obj.find(1).delete
      def delete
        perform_delete_and_parse self.class::EXCEPTION, "#{self.class::URL}/#{id}"
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
          parsed = perform_post_and_parse self::EXCEPTION, self::URL, payload
          new(parsed.transform_keys(&:to_sym))
        end

        # search or find objects
        # eg.
        #   1) finding single object
        #
        #   obj = Obj.find(1)
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
        #   Obj.find(pagination: true)
        #   {
        #     pagination: { page: 1, pageSize: 10, rowCount: 1, pageCount: 1 }
        #     data: [ <Obj:1>, <Obj:2>, ... ]
        #   }
        #   # return an hash object with pagination and data field.
        #   # page is current page
        #   # pageSize is the size of the data in a page
        #   # rowCount is the total count of data
        #   # pageCount is the total count of page.
        #   # data is the array of Objects
        #   # Note: by default pagination is set to false
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

        # get first object
        # eg.
        #   Obj.first
        #   # => <Obj1>
        #
        def first
          find(page_size: 1)[0]
        end

        # get last object
        # eg.
        #   Obj.last
        #   # => <Obj10>
        #
        def last
          find(page: count, page_size: 1)[0]
        end

        # get total count
        # eg.
        #   Obj.count
        #   # => 10
        #
        def count
          find(page_size: 1, pagination: true)[:pagination][:rowCount]
        end

        private

        def find_with(pagination: false, **opts)
          params = opts.map { |k, v| "#{k}=#{v}" }.join('&')
          url = "#{self::URL}?#{params}"
          parsed = perform_get_and_parse self::EXCEPTION, url
          data = parsed['data'].map { |d| new(d.transform_keys(&:to_sym)) }
          if pagination
            { pagination: parsed['pagination'].transform_keys(&:to_sym),
              data: data }
          else
            data
          end
        end

        def find_by_id(id)
          raise ArgumentError, 'argument is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse self::EXCEPTION, "#{self::URL}/#{id}"
          new(parsed.transform_keys!(&:to_sym))
        end
      end
    end
  end
end
