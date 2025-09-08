# frozen_string_literal: true

module Volcanic::Authenticator
  # URN provides all of the support needed to generated and parse urns
  class URN
    MATCH_RE = %r{^user:\/\/([a-z\d-]+)\/([a-z\d-]+)\/([a-z\d]+)\/?([a-z\d]+)?$}

    class << self
      def parse(value)
        return value if value.is_a? URN

        captures = value.match(URN::MATCH_RE).captures
        raise ArgumentError, "Invalid urn: #{value}" if captures.nil?

        new(
          stack_id: captures[0], dataset_id: captures[1],
          principal_id: captures[2], identity_id: captures[3]
        )
      rescue NoMethodError
        raise ArgumentError, "Invalid urn: #{value}"
      end
    end

    def initialize(stack_id:, dataset_id:, principal_id:, identity_id: nil)
      @stack_id = stack_id
      @dataset_id = dataset_id.to_s
      @principal_id = principal_id.to_s
      @identity_id = identity_id.nil? ? identity_id : identity_id.to_s
    end

    def to_s
      base = "user://#{stack_id}/#{dataset_id}/#{principal_id}"
      identity_id.blank? ? base : "#{base}/#{identity_id}"
    end

    def ==(other)
      other = self.class.parse(other)
      stack_id == other.stack_id &&
        dataset_id == other.dataset_id &&
        principal_id == other.principal_id &&
        identity_id == other.identity_id
    rescue ArgumentError
      false
    end

    attr_accessor :stack_id, :dataset_id, :principal_id, :identity_id
  end
end
