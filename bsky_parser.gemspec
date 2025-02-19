Gem::Specification.new do |s|
  s.name        = "bsky-parser"
  s.version     = "1.0.0"
  s.summary     = "Parses text and generates Bluesky rich text facets"
  s.authors     = ["Jonathan Yeong"]
  s.email       = "hey@jonathanyeong.com"
  s.files       = ["lib/bsky_parser.rb"]
  s.homepage    = "https://rubygems.org/gems/bsky_parser"
  s.metadata    = {
    "source_code_uri" => "https://github.com/jonathanyeong/bsky-parser"
  }
  s.license       = "MIT"
  s.required_ruby_version = ">= 3.3.6"
  s.add_dependency "faraday", "~> 2.12.2"
end