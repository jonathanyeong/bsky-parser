# frozen_string_literal: true

require "test_helper"

module BskyParser
  module Facets
    class TestTagFacet < Minitest::Test
      def test_basic_hashtag
        content = "#hello"
        facets = TagFacet.process(content)

        assert_equal 1, facets.length

        facet = facets.first

        assert_equal 0, facet[:index][:byteStart]
        # The range has an inclusive start and an exclusive end.
        # That means the end number goes 1 past what you might expect.
        # https://docs.bsky.app/docs/advanced-guides/post-richtext
        assert_equal 6, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#tag", feature[:$type]
        assert_equal "hello", feature[:tag]
      end

      def test_multiple_hashtags
        content = "#hello #world"
        facets = TagFacet.process(content)

        assert_equal 2, facets.length

        assert_equal "hello", facets[0][:features][0][:tag]
        assert_equal 0, facets[0][:index][:byteStart]
        assert_equal 6, facets[0][:index][:byteEnd]

        # Second hashtag
        assert_equal "world", facets[1][:features][0][:tag]
        assert_equal 7, facets[1][:index][:byteStart]
        assert_equal 13, facets[1][:index][:byteEnd]
      end

      def test_no_hashtags
        content = "hello world"
        facets = TagFacet.process(content)

        assert_equal 0, facets.length
      end

      def test_complex_hashtag
        content = "#hello123!!!"
        facets = TagFacet.process(content)

        assert_equal 1, facets.length

        facet = facets.first

        assert_equal 0, facet[:index][:byteStart]
        # The range has an inclusive start and an exclusive end.
        # That means the end number goes 1 past what you might expect.
        # https://docs.bsky.app/docs/advanced-guides/post-richtext
        assert_equal 9, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#tag", feature[:$type]
        assert_equal "hello123", feature[:tag]
      end

      def test_hashtag_in_middle_of_text
        content = "hello#world"
        facets = TagFacet.process(content)

        # Behaviour mimics bsky.app
        assert_equal 0, facets.length
      end
    end
  end
end
