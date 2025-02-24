# frozen_string_literal: true

require_relative "base_facet"

module BskyParser
  module Facets
    class URLFacet < BaseFacet
      def process
        facets = []
        # URL pattern from https://docs.bsky.app/docs/advanced-guides/post-richtext
        url_pattern = %r{(^|\s)(https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&/=]*[-a-zA-Z0-9@%_\+~#/=])?)}

        matches = content.to_enum(:scan, url_pattern).map do
          match = Regexp.last_match
          # If there's a space before the hashtag (match[1] contains a space),
          # adjust the start position by adding 1
          start_offset = match[1]&.length || 0

          {
            url: match[0],
            indices: [match.begin(0) + start_offset, match.end(0)]
          }
        end

        matches.each do |match|
          url = match[:url].to_s.lstrip
          indices = match[:indices]
          facets << build_facet(indices, url)
        end
        facets
      end

      private

      def build_facet(indices, url)
        {
          index: {
            byteStart: indices[0],
            byteEnd: indices[1]
          },
          features: [{
            "$type": "app.bsky.richtext.facet#link",
            uri: url
          }]
        }
      end
    end
  end
end
