# frozen_string_literal: true

require_relative "base_facet"

module BskyParser
  module Facets
    class MentionFacet < BaseFacet
      BASE_URL = "https://bsky.social"

      def process
        facets = []
        # regex based on: https://atproto.com/specs/handle#handle-identifier-syntax
        mention_pattern = /(^|\s)(@([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)/
        matches = content.to_enum(:scan, mention_pattern).map do
          match = Regexp.last_match
          start_offset = match[1]&.length || 0

          {
            handle: match[0],
            indices: [match.begin(0) + start_offset, match.end(0)]
          }
        end

        matches.each do |match|
          handle = match[:handle].to_s.strip[1..] # Trim leading @
          indices = match[:indices]
          begin
            resp = conn.get("/xrpc/com.atproto.identity.resolveHandle", { handle: handle })
            if resp.success?
              handle_did = JSON.parse(resp.body)["did"]
              facets << build_facet(indices, handle_did)
            end
          rescue Faraday::Error
            # TODO: Introduce logging
            continue
          end
        end
        facets
      end

      private

      def conn
        @conn ||= Faraday.new(url: BASE_URL) do |f|
          f.request :json
        end
      end

      def build_facet(indices, handle_did)
        {
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
    end
  end
end
