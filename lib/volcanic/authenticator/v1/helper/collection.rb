# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # collection helper
    # this class extend array class with a few custom gettter and setter
    class Collection < Array
      attr_accessor :page, :page_size, :row_count, :page_count

      def initialize(array, **page_information)
        @page = page_information[:page]
        @page_size =  page_information[:pageSize]
        @row_count =  page_information[:rowCount]
        @page_count = page_information[:pageCount]
        super array
      end
    end
  end
end
