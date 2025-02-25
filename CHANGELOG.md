## [Unreleased]

## [1.0.2] - 2025-02-25

### Fixed

- Fix tag facet regex. Previously, it would match this entire string: `#hello!`. Now it correctly matches `#hello` without the `!`.
- Regex patterns for mentions, tags, and URL facets correctly match when they appear at the beginning of text without requiring a leading space. For example, `"#hello"` is now properly detected as a tag, while mid-word occurrences like `"hello#hello"` are still ignored.
- URL facet has been fixed to not match if it occurs mid-word. E.g. `hellohttps://example.com` no longer matches.
- Correctly handle indices to take into account of leading space with multiple matches.

## [1.0.1] - 2025-02-19

### Added
- More files from bundle gem generator. Originally, I followed the rubygem guide which listed less files.
- Added LICENSE

### Fixed
- Fixed Rubocop linting rule errors.

## [1.0.0] - 2025-02-19

- Initial Release.
