# frozen_string_literal: true

require_relative "bsky_parser/version"
require_relative "bsky_parser/facets/tag_facet"
require_relative "bsky_parser/facets/url_facet"
require_relative "bsky_parser/facets/mention_facet"

require "faraday"

module BskyParser
  class << self
    BASE_URL = "https://bsky.social"

    def parse(content)
      parsed_content, mkdown_facets = process_markdown_links(content)

      facets =
        mkdown_facets +
        Facets::TagFacet.process(parsed_content) +
        Facets::MentionFacet.process(parsed_content) +
        Facets::UrlFacet.process(parsed_content)

      [parsed_content, facets]
    end

    private

    def mkdown_links(content)
      url_pattern = %r{\[(?<text>[^\]]+)\]\((?<url>https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&/=]*[-a-zA-Z0-9@%_\+~#/=])?)\)}
      matches = content.to_enum(:scan, url_pattern).map { Regexp.last_match }

      mkdown_links = []
      matches.each do |match|
        mkdown_links << {
          text: match[:text],
          link: match[:url],
          match: match.to_s
        }
      end
      mkdown_links
    end

    def process_markdown_links(content)
      facets = []
      result_text = content.dup

      links = mkdown_links(content)

      links.reverse_each do |link|
        start_pos = result_text.index(link[:match])

        next unless start_pos

        end_pos = start_pos + link[:match].length

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

        result_text[start_pos...end_pos] = link[:text]
      end

      [result_text, facets]
    end
  end
end
