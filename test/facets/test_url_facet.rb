# frozen_string_literal: true

require "test_helper"

module BskyParser
  module Facets
    class TestURLFacet < Minitest::Test
      def test_basic_url
        content = "https://example.com"
        facets = URLFacet.process(content)

        assert_equal 1, facets.length

        facet = facets.first

        assert_equal 0, facet[:index][:byteStart]
        assert_equal content.length, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#link", feature[:$type]
        assert_equal "https://example.com", feature[:uri]
      end

      def test_basic_www_url
        content = "https://www.example.com"
        facets = URLFacet.process(content)

        assert_equal 1, facets.length

        facet = facets.first

        assert_equal 0, facet[:index][:byteStart]
        assert_equal content.length, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#link", feature[:$type]
        assert_equal "https://www.example.com", feature[:uri]
      end

      def test_multiple_urls
        test_url_one = "https://example.com"
        test_url_two = "https://test.com"
        content = "#{test_url_one} #{test_url_two}"
        facets = URLFacet.process(content)

        assert_equal 2, facets.length

        assert_equal test_url_one, facets[0][:features].first[:uri]
        assert_equal 0, facets[0][:index][:byteStart]
        assert_equal test_url_one.length, facets[0][:index][:byteEnd]

        assert_equal test_url_two, facets[1][:features].first[:uri]
        assert_equal test_url_one.length + 1, facets[1][:index][:byteStart]
        assert_equal test_url_one.length + 1 + test_url_two.length, facets[1][:index][:byteEnd]
      end

      def test_no_urls
        content = "hello world"
        facets = URLFacet.process(content)

        assert_empty facets
      end

      def test_invalid_url
        content = "hello worldhttps://example.com"
        facets = URLFacet.process(content)

        assert_empty facets
      end

      def test_url_with_path_and_query
        content = "https://example.com/path?query=123"
        facets = URLFacet.process(content)

        assert_equal 1, facets.length

        assert_equal 0, facets[0][:index][:byteStart]
        assert_equal content.length, facets[0][:index][:byteEnd]

        assert_equal content, facets.first[:features].first[:uri]
      end

      def test_url_with_www
        content = "https://www.example.com"
        facets = URLFacet.process(content)

        assert_equal 1, facets.length

        assert_equal 0, facets[0][:index][:byteStart]
        assert_equal content.length, facets[0][:index][:byteEnd]

        assert_equal content, facets.first[:features].first[:uri]
      end

      def test_url_in_message
        test_url = "https://example.com"
        content = "Hello world #{test_url} check it out"
        facets = URLFacet.process(content)

        assert_equal 1, facets.length

        assert_equal "Hello world ".length, facets[0][:index][:byteStart]
        assert_equal "Hello world ".length + test_url.length, facets[0][:index][:byteEnd]

        assert_equal test_url, facets.first[:features].first[:uri]
      end
    end
  end
end
