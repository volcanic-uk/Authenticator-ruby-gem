# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # collection helper
    # this class extend array class with a few custom gettter and setter
    class Collection < Array
      attr_accessor :page, :page_size, :row_count, :page_count

      def initialize(array, page: nil, page_size: nil, row_count: nil, page_count: nil, **_opts)
        @page = page
        @page_size = page_size
        @row_count = row_count
        @page_count = page_count
        super array
      end
    end
  end
end
