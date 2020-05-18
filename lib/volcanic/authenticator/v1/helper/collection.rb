# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # collection helper
    # this class extend array class with a few custom gettter and setter
    class Collection < Array
      KEYS_FROM_AUTH_SERVICE = { pageSize: :page_size, rowCount: :row_count, pageCount: :page_count }.freeze

      attr_accessor :page, :page_size, :row_count, :page_count

      def initialize(array, page: nil, page_size: nil, row_count: nil, page_count: nil, **_opts)
        @page = page
        @page_size = page_size
        @row_count = row_count
        @page_count = page_count
        super array
      end

      def concat(other)
        @page = @page_size = @page_count = nil
        super other
      end

      # converting camel case to a snake case style
      def self.from_auth_service(array, **args)
        KEYS_FROM_AUTH_SERVICE.each do |svc_key, ruby_key|
          args[ruby_key] = args.delete(svc_key) if args.key?(svc_key)
        end
        new(array, **args)
      end
    end
  end
end
