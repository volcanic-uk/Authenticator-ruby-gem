# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # collection helper
    # this class extend array class with a few custom gettter and setter
    class Collection < Array
      attr_accessor :page, :page_size, :row_count, :page_count

      # rubocop:disable Naming/UncommunicativeMethodParamName
      # rubocop:disable Naming/VariableName:
      def initialize(array, page: nil, pageSize: nil, rowCount: nil, pageCount: nil, **_opts)
        @page = page
        @page_size = pageSize
        @row_count = rowCount
        @page_count = pageCount
        super array
      end
      # rubocop:enable Naming/UncommunicativeMethodParamName
      # rubocop:enable Naming/VariableName:
    end
  end
end
