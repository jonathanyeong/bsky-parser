# frozen_string_literal: true

require "test_helper"

class TestBskyParser < Minitest::Test
  def setup
    WebMock.disable_net_connect!
    @handle = "alice.bsky.app"
    @did = "did:plc:alice123456"
    @tag = "testing"
    @url = "https://example.com/page"
    @link_text = "my website"
    @link_url = "https://mysite.com"

    @content = "Check out [#{@link_text}](#{@link_url}) and follow @#{@handle}. " \
               "Don't forget to use ##{@tag} when sharing #{@url} with others!"

    @expected_content = "Check out #{@link_text} and follow @#{@handle}. " \
                        "Don't forget to use ##{@tag} when sharing #{@url} with others!"

    stub_request(:get, "#{BskyParser::Facets::MentionFacet::BASE_URL}/xrpc/com.atproto.identity.resolveHandle")
      .with(query: { handle: @handle })
      .to_return(
        status: 200,
        body: { did: @did }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  def teardown
    WebMock.reset!
  end

  def test_markdown_links_get_replaced
    parsed_content, = BskyParser.parse(@content)

    assert_equal @expected_content, parsed_content
  end

  def test_correct_number_of_facets_parsed
    _, facets = BskyParser.parse(@content)

    assert_equal 4, facets.length

    link_facet = facets.find { |f| f[:features].first[:uri] == @link_url }
    mention_facet = facets.find { |f| f[:features].first[:$type] == "app.bsky.richtext.facet#mention" }
    tag_facet = facets.find { |f| f[:features].first[:$type] == "app.bsky.richtext.facet#tag" }
    url_facet = facets.find { |f| f[:features].first[:uri] == @url }

    assert link_facet, "Markdown link facet not found"
    assert mention_facet, "Mention facet not found"
    assert tag_facet, "Tag facet not found"
    assert url_facet, "URL facet not found"
  end

  def test_parse_with_all_facet_types
    parsed_content, facets = BskyParser.parse(@content)

    link_facet = facets.find { |f| f[:features].first[:uri] == @link_url }
    mention_facet = facets.find { |f| f[:features].first[:$type] == "app.bsky.richtext.facet#mention" }
    tag_facet = facets.find { |f| f[:features].first[:$type] == "app.bsky.richtext.facet#tag" }
    url_facet = facets.find { |f| f[:features].first[:uri] == @url }

    link_start = parsed_content.index(@link_text)

    assert_equal link_start, link_facet[:index][:byteStart]
    assert_equal link_start + @link_text.length, link_facet[:index][:byteEnd]
    assert_equal @link_url, link_facet[:features].first[:uri]

    # Verify mention facet
    mention_start = parsed_content.index("@#{@handle}")

    assert_equal mention_start, mention_facet[:index][:byteStart]
    assert_equal mention_start + "@#{@handle}".length, mention_facet[:index][:byteEnd]
    assert_equal @did, mention_facet[:features].first[:did]

    # Verify tag facet
    tag_start = parsed_content.index("##{@tag}")

    assert_equal tag_start, tag_facet[:index][:byteStart]
    assert_equal tag_start + "##{@tag}".length, tag_facet[:index][:byteEnd]
    assert_equal @tag, tag_facet[:features].first[:tag]

    # Verify URL facet
    url_start = parsed_content.index(@url)

    assert_equal url_start, url_facet[:index][:byteStart]
    assert_equal url_start + @url.length, url_facet[:index][:byteEnd]
    assert_equal @url, url_facet[:features].first[:uri]
  end

  def test_that_it_has_a_version_number
    refute_nil ::BskyParser::VERSION
  end
end
