# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Given a scope will contain optional wildcards or exact values
    # we need to break out the scope into core parts and validate.
    class Scope
      MATCH_RE = %r{^vrn:([a-z\d\-\*]+):([a-z\d\-\*]+):([a-z][a-z-]*|\*?)(?:\/([\da-z\.-]+|\*))?(?:\?(\S+))?$}.freeze
      SCORES = { stack_id: 1, dataset_id: 2, resource: 3, resource_id: 4, qualifiers: 5 }.freeze

      class << self
        def parse(value)
          return value if value.is_a? Scope

          captures = value.match(Scope::MATCH_RE).captures
          raise ArgumentError, message: "Invalid scope: #{value}" if captures.nil?

          new(
            stack_id: captures[0], dataset_id: captures[1], resource: captures[2],
            resource_id: captures[3], qualifiers: captures[4]
          )
        rescue NoMethodError
          raise ArgumentError, message: "Invalid scope: #{value}"
        end
      end

      def initialize(stack_id: '*', dataset_id: '*', resource: '*', resource_id: nil, qualifiers: nil)
        @stack_id = stack_id
        @dataset_id = dataset_id.to_s
        @resource = resource
        @resource_id = resource_id.nil? ? resource_id : resource_id.to_s
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

      def vrn_without_qualifiers
        base = "vrn:#{stack_id}:#{dataset_id}:#{resource}"
        base += "/#{resource_id}" if resource_id
        base
      end

      def <=>(other)
        specificity_score <=> other.specificity_score
      end

      def ==(other)
        other = self.class.parse(other) if other.is_a?(String)
        %i[@stack_id @dataset_id @resource @resource_id @qualifiers].all? do |field|
          instance_variable_get(field) == other.instance_variable_get(field)
        end
      end

      # For each element in the VRN, assign it a value
      # element = * (0)
      # Stack adds 1
      # Dataset adds 2
      # Resource adds 3
      # ResourceId adds 4
      # Qualifiers adds 5
      def specificity_score
        %i[stack_id dataset_id resource resource_id qualifiers].reduce(0) do |acc, element|
          val = if !send(element).blank? && send(element) != '*'
                  SCORES.fetch(element)
                else
                  0
                end
          acc + val
        end
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
