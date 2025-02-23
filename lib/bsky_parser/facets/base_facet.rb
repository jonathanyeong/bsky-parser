# frozen_string_literal: true

module BskyParser
  module Facets
    class BaseFacet
      def self.process(content)
        new(content).process
      end

      attr_reader :content

      def initialize(content)
        @content = content
      end

      def process
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
