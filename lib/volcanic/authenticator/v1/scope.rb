# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Given a scope will contain optional wildcards or exact values
    # we need to break out the scope into core parts and validate.
    class Scope
      SCORES = { stack_id: 1, dataset_id: 2, resource: 3, resource_id: 4, qualifiers: 5 }.freeze

      class << self
        def parse(value)
          return value if value.is_a? Scope
          raise ArgumentError, "Invalid scope: #{value}" unless value.is_a?(String)

          _, stack_id, dataset_id, resource = *value.split(':', 4)
          raise ArgumentError, "Invalid scope: #{value}" if resource.nil?

          resource, qualifiers = *resource.split('?', 2)
          resource_name, resource_id = *resource.split('/', 2)

          new(stack_id: stack_id, dataset_id: dataset_id, resource: resource_name,
              resource_id: resource_id, qualifiers: qualifiers)
        end
      end

      def initialize(stack_id: '*', dataset_id: '*', resource: '*', resource_id: nil, qualifiers: nil)
        @stack_id = stack_id
        @dataset_id = dataset_id.to_s
        @resource = resource
        @resource_id = resource_id.nil? ? resource_id : resource_id.to_s
        self.qualifiers = qualifiers.nil? ? {} : qualifiers
        { stack_id: stack_id, dataset_id: dataset_id,
          resource: resource, resource_id: resource_id }.each do |key, value|
          raise ArgumentError, "#{value} is not a valid #{key}" unless send("valid_#{key}?", value)
        end
      end

      def include?(other)
        other = Scope.parse(other)

        res = stack_included?(other) && dataset_included?(other) &&
              resource_included?(other) && resource_id_included?(other)

        if res && block_given?
          yield qualifiers
        else
          res
        end
      end

      def to_s
        base = vrn_without_qualifiers
        base += "?#{qualifiers.map { |k, v| "#{k}=#{v}" }.join('&')}" unless qualifiers.empty?
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

      def qualifiers=(value)
        case value
        when Hash
          @qualifiers = value
        when String
          @qualifiers = Hash[value.split('&').map { |item| item.split('=') }]
        when nil
          @qualifiers = nil
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

      def valid_stack_id?(value)
        !value.nil? && value.match(/^[a-z\d\-]+$/) || value == '*' || value == '{stack}'
      end

      def valid_dataset_id?(value)
        !value.nil? && value.match(/^[a-z\d\-]+$/) || value == '*' || value == '{dataset}'
      end

      def valid_resource?(value)
        !value.nil? && value.match(/^[a-z\d][a-z\d\-_]*$/) || value == '*'
      end

      def valid_resource_id?(value)
        value.nil? || value.match(/^[a-z\d\-]+$/) || value == '*' ||
          %w[{self} {identity} {principal}].include?(value)
      end
    end
  end
end
