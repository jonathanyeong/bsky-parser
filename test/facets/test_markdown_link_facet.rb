# frozen_string_literal: true

require "test_helper"

module BskyParser
  module Facets
    class TestMarkdownLinkFacet < Minitest::Test
      def test_basic_markdown_link
        link_text = "click here"
        link_url = "https://example.com"
        content = "[#{link_text}](#{link_url})"

        result_text, facets = MarkdownLinkFacet.process(content)

        # Check the transformed text
        assert_equal link_text, result_text

        # Check the facets
        assert_equal 1, facets.length
        facet = facets.first

        assert_equal 0, facet[:index][:byteStart]
        assert_equal link_text.length, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#link", feature[:$type]
        assert_equal link_url, feature[:uri]
      end

      def test_multiple_markdown_links
        link1_text = "first link"
        link1_url = "https://example.com/1"
        link2_text = "second link"
        link2_url = "https://example.com/2"

        content = "Here's a [#{link1_text}](#{link1_url}) and another [#{link2_text}](#{link2_url})."

        result_text, facets = MarkdownLinkFacet.process(content)

        # Check the transformed text
        expected_text = "Here's a #{link1_text} and another #{link2_text}."

        assert_equal expected_text, result_text

        # Check the facets
        assert_equal 2, facets.length

        # First link facet
        facet1_start = "Here's a ".length

        assert_equal facet1_start, facets[0][:index][:byteStart]
        assert_equal facet1_start + link1_text.length, facets[0][:index][:byteEnd]
        assert_equal link1_url, facets[0][:features].first[:uri]

        # Second link facet
        facet2_start = expected_text.index(link2_text)

        assert_equal facet2_start, facets[1][:index][:byteStart]
        assert_equal facet2_start + link2_text.length, facets[1][:index][:byteEnd]
        assert_equal link2_url, facets[1][:features].first[:uri]
      end

      def test_multiple_markdown_links_same_text
        link1_text = "link"
        link1_url = "https://example.com/1"
        link2_text = "link"
        link2_url = "https://example.com/2"

        content = "Here's a [#{link1_text}](#{link1_url}) and another [#{link2_text}](#{link2_url})."

        result_text, facets = MarkdownLinkFacet.process(content)

        # Check the transformed text
        expected_text = "Here's a #{link1_text} and another #{link2_text}."

        assert_equal expected_text, result_text

        # Check the facets
        assert_equal 2, facets.length

        # First link facet
        facet1_start = "Here's a ".length

        assert_equal facet1_start, facets[0][:index][:byteStart]
        assert_equal facet1_start + link1_text.length, facets[0][:index][:byteEnd]
        assert_equal link1_url, facets[0][:features].first[:uri]

        # Second link facet
        facet2_start = "Here's a #{link1_text} and another ".length

        assert_equal facet2_start, facets[1][:index][:byteStart]
        assert_equal facet2_start + link2_text.length, facets[1][:index][:byteEnd]
        assert_equal link2_url, facets[1][:features].first[:uri]
      end

      def test_no_markdown_links
        content = "This is plain text with no markdown links."

        result_text, facets = MarkdownLinkFacet.process(content)

        # Text should remain unchanged
        assert_equal content, result_text

        # No facets should be generated
        assert_empty facets
      end
    end
  end
end
