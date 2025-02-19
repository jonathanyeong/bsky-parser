# Bsky Parser

> [!WARNING]
> API is stable but development is still in progress. Aka no tests yet!

Gem that will parse text content and generate Bluesky rich text facets.

Facets supported:

- Mentions aka @handles
- Hashtags
- URLs as well as markdown-style links

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add bsky-parser
$ bundle install
```

## Usage

The gem provides a simple interface to parse text content:

```ruby
content = "Check out this blog post [My Blog](https://example.com) and follow @handle.bsky.social! #ruby"
parsed_content, facets = BskyParser.parse(content)

# Example usage:
# request_body = {
#   repo: user_did,
#   collection: "app.bsky.feed.post",
#   record: {
#     text: parsed_content,
#     facets: facets,
#     createdAt: current_time,
#     "$type": "app.bsky.feed.post"
#   }
# }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/jonathanyeong/bsky-parser/blob/main/LICENSE).