# frozen_string_literal: true

require_relative "bsky_parser/version"
require_relative "bsky_parser/facets/markdown_link_facet"
require_relative "bsky_parser/facets/tag_facet"
require_relative "bsky_parser/facets/url_facet"
require_relative "bsky_parser/facets/mention_facet"

require "faraday"

module BskyParser
  class << self
    def parse(content)
      parsed_content, mkdown_facets = Facets::MarkdownLinkFacet.process(content)

      facets =
        mkdown_facets +
        Facets::TagFacet.process(parsed_content) +
        Facets::MentionFacet.process(parsed_content) +
        Facets::URLFacet.process(parsed_content)

      [parsed_content, facets]
    end
  end
end
