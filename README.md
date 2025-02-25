# Bsky Parser

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
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jonathanyeong/bsky_parser/blob/main/CODE_OF_CONDUCT.md).

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/jonathanyeong/bsky-parser/blob/main/LICENSE).