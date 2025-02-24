# frozen_string_literal: true

require_relative "base_facet"

module BskyParser
  module Facets
    class TagFacet < BaseFacet
      def process
        facets = []
        tag_pattern = /(^|\s)#[\w-]+/
        matches = content.to_enum(:scan, tag_pattern).map do
          match = Regexp.last_match
          # If there's a space before the hashtag (match[1] contains a space),
          # adjust the start position by adding 1
          start_offset = match[1]&.length || 0

          {
            tag: match[0],
            indices: [match.begin(0) + start_offset, match.end(0)]
          }
        end

        matches.each do |match|
          tag = match[:tag].to_s.lstrip[1..] # Trim leading space and hashtag
          indices = match[:indices]
          facets << build_facet(indices, tag)
        end

        facets
      end

      private

      def build_facet(indices, tag)
        {
          index: {
            byteStart: indices[0],
            byteEnd: indices[1]
          },
          features: [{
            "$type": "app.bsky.richtext.facet#tag",
            tag: tag
          }]
        }
      end
    end
  end
end
