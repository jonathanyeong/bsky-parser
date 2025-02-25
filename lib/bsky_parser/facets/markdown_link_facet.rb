# frozen_string_literal: true

require_relative "base_facet"

module BskyParser
  module Facets
    class MarkdownLinkFacet < BaseFacet
      # Override class method to return both modified content and facets
      def self.process(content)
        new(content).process
      end

      def process
        facets = []
        result_text = content.dup
        links = find_markdown_links

        links.each do |link|
          start_pos = result_text.index(link[:match])
          next unless start_pos

          end_pos = start_pos + link[:match].length

          # Replace markdown syntax with just the text
          result_text[start_pos...end_pos] = link[:text]

          facets << {
            index: {
              byteStart: start_pos,
              byteEnd: start_pos + link[:text].length
            },
            features: [{
              "$type": "app.bsky.richtext.facet#link",
              uri: link[:link]
            }]
          }
        end

        [result_text, facets]
      end

      private

      def url_pattern
        %r{
          \[
            (?<text>[^\]]+)                # The link text inside square brackets
          \]
          \(
            (?<url>
              https?://                     # http:// or https://
              (www\.)?                      # Optional www.
              [-a-zA-Z0-9@:%._\+~#=]{1,256} # Domain name
              \.
              [a-zA-Z0-9()]{1,6}            # TLD
              \b
              ([-a-zA-Z0-9()@:%_\+.~#?&/=]* # URL path, params, etc.
              [-a-zA-Z0-9@%_\+~#/=])?
            )
          \)
        }x
      end

      def find_markdown_links
        content.to_enum(:scan, url_pattern).map do
          match = Regexp.last_match
          {
            text: match[:text],
            link: match[:url],
            match: match.to_s
          }
        end
      end
    end
  end
end
