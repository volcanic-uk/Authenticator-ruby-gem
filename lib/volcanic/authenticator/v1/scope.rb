# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Given a scope will contain optional wildcards or exact values
    # we need to break out the scope into core parts and validate.
    class Scope
      MATCH_RE = %r{^vrn:([a-z\d\-\*]+):([a-z\d\-\*]+):([a-z][a-z-]*|\*?)(?:\/([\da-z\.-]+|\*))?(?:\?(\S+))?$}.freeze

      class << self
        def parse(value)
          captures = value.match(Scope::MATCH_RE).captures
          new(
            stack_id: captures[0], dataset_id: captures[1], resource: captures[2],
            resource_id: captures[3], qualifiers: captures[4]
          )
        rescue NoMethodError
          raise ScopeError, message: "Invalid scope: #{value}"
        end
      end

      def initialize(stack_id: '*', dataset_id: '*', resource: '*', resource_id: nil, qualifiers: nil)
        @stack_id = stack_id
        @dataset_id = dataset_id
        @resource = resource
        @resource_id = resource_id
        @qualifiers = qualifiers
      end

      def include?(other)
        other = Scope.parse(other) if other.is_a? String
        return false unless other.is_a? Scope

        stack_included?(other) &&
          dataset_included?(other) &&
          resource_included?(other) &&
          resource_id_included?(other)
      end

      def to_s
        base = "vrn:#{stack_id}:#{dataset_id}:#{resource}"
        base += "/#{resource_id}" if resource_id
        base += "?#{qualifiers}" if qualifiers
        base
      end

      attr_reader :stack_id, :dataset_id, :resource, :resource_id, :qualifiers

      private

      def stack_included?(other)
        stack_id == '*' || stack_id == other.stack_id
      end

      def dataset_included?(other)
        dataset_id == '*' || dataset_id == other.dataset_id
      end

      def resource_included?(other)
        resource == '*' || resource == other.resource
      end

      def resource_id_included?(other)
        (resource == '*' && resource_id.blank?) || resource_id == '*' || resource_id == other.resource_id
      end
    end
  end
end
