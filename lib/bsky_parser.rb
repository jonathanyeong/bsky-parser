# frozen_string_literal: true

require_relative "bsky_parser/version"

require "faraday"

module BskyParser
  class << self
    BASE_URL = "https://bsky.social"

    def parse(content)
      parsed_content, mkdown_facets = process_markdown_links(content)

      facets = mkdown_facets + tag_facets(parsed_content) + mention_facets(parsed_content) + url_facets(parsed_content)

      [parsed_content, facets]
    end

    private

    def conn
      @conn ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
      end
    end

    def tag_facets(content)
      facets = []
      tag_pattern = /#\S+/
      matches = content.to_enum(:scan, tag_pattern).map do
        { tag: Regexp.last_match, indices: Regexp.last_match.offset(0) }
      end
      matches.each do |match|
        tag = match[:tag].to_s[1..] # Trim leading hashtag
        indices = match[:indices]
        facets << {
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
      facets
    end

    def mention_facets(content)
      facets = []
      # regex based on: https://atproto.com/specs/handle#handle-identifier-syntax
      mention_pattern = /[$|\W](@([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)/
      matches = content.to_enum(:scan, mention_pattern).map do
        { handle: Regexp.last_match, indices: Regexp.last_match.offset(0) }
      end
      matches.each do |match|
        handle = match[:handle].to_s.strip[1..] # Trim leading @
        indices = match[:indices]
        resp = conn.get("/xrpc/com.atproto.identity.resolveHandle", { handle: handle })
        handle_did = JSON.parse(resp.body)["did"]
        facets << {
          index: {
            byteStart: indices[0],
            byteEnd: indices[1]
          },
          features: [{
            "$type": "app.bsky.richtext.facet#mention",
            did: handle_did
          }]
        }
      end
      facets
    end

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

    def url_facets(content)
      facets = []
      # URL pattern from https://docs.bsky.app/docs/advanced-guides/post-richtext
      url_pattern = %r{([$|\W])(https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&/=]*[-a-zA-Z0-9@%_\+~#/=])?)}
      matches = content.to_enum(:scan, url_pattern).map do
        { url: Regexp.last_match, indices: Regexp.last_match.offset(0) }
      end
      matches.each do |match|
        url = match[:url].to_s[1..]
        indices = match[:indices]
        facets << {
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
      facets
    end
  end
end
