# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Group Permission Api
    class GroupPermission
      attr_accessor :id

      def initialize(id:)
        @id = id
      end
    end
  end
end
