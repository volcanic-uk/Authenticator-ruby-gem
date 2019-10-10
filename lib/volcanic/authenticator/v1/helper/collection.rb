# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # collection helper
    # this class extend array class with a few custom gettter and setter
    class Collection < Array
      attr_accessor :page, :page_size, :row_count, :page_count

      def initialize(array, page: nil, pageSize: nil, rowCount: nil, pageCount: nil, **opts)
        @page = page
        @page_size = pageSize
        @row_count = rowCount
        @page_count = pageCount
        super array
      end
    end
  end
end
