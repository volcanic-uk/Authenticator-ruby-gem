# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Permission Api
    class Permission
      attr_accessor :id, :name, :privileges

      def initialize(id:, name: nil, privileges: nil)
        @id = id
        @name = name
        @privileges = privileges
      end
    end
  end
end
