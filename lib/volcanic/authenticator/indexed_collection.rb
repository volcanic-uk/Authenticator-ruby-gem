# frozen_string_literal: true

module Volcanic::Authenticator
  # A collection class to allow fast access to objects based on multiple values
  #
  # Use by creating an instance passing in a list of symbols to index items by
  #
  # Access the items by calling #by_<field> which will return a set of
  # those items matching (or empty set if there are no matches)
  #
  # Add new items using either #concat(enumerable) or #add(item)
  #
  # All items added must respond to methods with the same name as all of the index
  # fields
  #
  class IndexedCollection
    INDEXES = %i[id].freeze

    attr_reader :indexes

    def initialize(*indexes)
      @indexes = indexes.empty? ? INDEXES : indexes
      indexes.each do |index|
        instance_variable_set("@#{index}".to_sym, Hash.new { |h, k| h[k] = Set.new })
      end
    end

    def respond_to_missing?(meth, include_private = false)
      super || begin
        prefix, index = meth.to_s.match(/^([^_]+)_(.+)$/)&.captures
        prefix &&
          index &&
          respond_to?(prefix.to_sym, true, true) &&
          indexes.include?(index)
      end
    end

    def method_missing(meth, *args)
      prefix, index = meth.to_s.match(/^([^_]+)_(.+)$/)&.captures
      if respond_to?(prefix.to_sym, true) && indexes.include?(index.to_sym)
        send prefix.to_sym, index, args[0]
      else
        super
      end
    end

    def add(value)
      return nil if value.nil?

      indexes.each do |index|
        [value.send(index)].flatten.each do |key|
          instance_variable_get("@#{index}".to_sym)[key].add(value)
        end
      end
      value
    end

    def concat(collection)
      collection.each { |value| add value }
      self
    end

    private

    def by(index, value)
      instance_variable_get("@#{index}".to_sym)[value]
    end
  end
end
