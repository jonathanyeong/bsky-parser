# frozen_string_literal: true

require "test_helper"

module BskyParser
  module Facets
    class TestMentionFacet < Minitest::Test
      def setup
        WebMock.disable_net_connect!
      end

      def teardown
        WebMock.reset!
      end

      def test_basic_mention
        handle = "jono.bsky.app"
        did = "did:plc:abcdef123456"
        content = "@#{handle}"

        # Stub the API request
        stub_resolve_handle(handle, did)

        facets = MentionFacet.process(content)

        assert_equal 1, facets.length

        facet = facets.first

        assert_equal 0, facet[:index][:byteStart]
        assert_equal content.length, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#mention", feature[:$type]
        assert_equal did, feature[:did]
      end

      def test_multiple_mentions
        handle1 = "alice.bsky.app"
        handle2 = "bob.bsky.app"
        did1 = "did:plc:alice123456"
        did2 = "did:plc:bob123456"
        content = "Hey @#{handle1} and @#{handle2} check this out"

        # Stub the API requests
        stub_resolve_handle(handle1, did1)
        stub_resolve_handle(handle2, did2)

        facets = MentionFacet.process(content)

        assert_equal 2, facets.length

        # First mention
        assert_equal "Hey ".length, facets[0][:index][:byteStart]
        assert_equal "Hey @#{handle1}".length, facets[0][:index][:byteEnd]
        assert_equal did1, facets[0][:features].first[:did]

        # Second mention
        assert_equal "Hey @#{handle1} and ".length, facets[1][:index][:byteStart]
        assert_equal "Hey @#{handle1} and @#{handle2}".length, facets[1][:index][:byteEnd]
        assert_equal did2, facets[1][:features].first[:did]
      end

      def test_no_mentions
        content = "Hello world with no mentions"

        facets = MentionFacet.process(content)

        assert_empty facets
      end

      def test_handle_not_found
        handle = "nonexistent.bsky.app"
        content = "@#{handle}"

        # Stub a failed API request
        stub_request(:get, "#{BskyParser::Facets::MentionFacet::BASE_URL}/xrpc/com.atproto.identity.resolveHandle")
          .with(query: { handle: handle })
          .to_return(status: 400, body: {
            error: "InvalidRequest",
            message: "Unable to resolve handle"
          }.to_json)

        facets = MentionFacet.process(content)

        assert_empty facets
      end

      def test_mix_of_valid_and_nonexistant_handles
        handle1 = "nonexistent.bsky.app"
        handle2 = "jono.bsky.app"
        did = "did:plc:jono123456"
        content = "@#{handle1} @#{handle2}"

        stub_request(:get, "#{BskyParser::Facets::MentionFacet::BASE_URL}/xrpc/com.atproto.identity.resolveHandle")
          .with(query: { handle: handle1 })
          .to_return(status: 400, body: {
            error: "InvalidRequest",
            message: "Unable to resolve handle"
          }.to_json)

        stub_resolve_handle(handle2, did)

        facets = MentionFacet.process(content)

        assert_equal 1, facets.length

        facet = facets.first

        assert_equal "@#{handle1} ".length, facet[:index][:byteStart]
        assert_equal content.length, facet[:index][:byteEnd]

        feature = facet[:features].first

        assert_equal "app.bsky.richtext.facet#mention", feature[:$type]
        assert_equal did, feature[:did]
      end

      private

      def stub_resolve_handle(handle, did)
        stub_request(:get, "#{BskyParser::Facets::MentionFacet::BASE_URL}/xrpc/com.atproto.identity.resolveHandle")
          .with(query: { handle: handle })
          .to_return(
            status: 200,
            body: { did: did }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end
    end
  end
end
