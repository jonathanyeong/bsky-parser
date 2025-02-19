# frozen_string_literal: true

require_relative "lib/bsky_parser/version"

Gem::Specification.new do |s|
  s.name        = "bsky_parser"
  s.version     = BskyParser::Version
  s.summary     = "Parses text and generates Bluesky rich text facets"
  s.authors     = ["Jonathan Yeong"]
  s.email       = "hey@jonathanyeong.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  s.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  s.bindir = "exe"
  s.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.homepage    = "https://github.com/jonathanyeong/bsky-parser"
  s.metadata    = {
    "homepage_uri"  => s.homepage,
    "source_code_uri" => "https://github.com/jonathanyeong/bsky-parser",
    "bug_tracker_uri" => "https://github.com/jonathanyeong/bsky-parser/issues"
  }
  s.license       = "MIT"
  s.required_ruby_version = ">= 3.3.6"
  s.add_dependency "faraday", "~> 2.12.2"
end