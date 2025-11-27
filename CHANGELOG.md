# changelog

all notable changes to this project will be documented in this file.

the format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

## [0.2.1] - 2025-01-27

### fixed

- heading font sizes now use explicit multiplication to avoid Typst's em unit stacking bug

### changed

- introduced `font-size` variable for consistent sizing
- updated heading sizes: title 2.2×, h1 1.75×, h2 1.4×, h3 1.12×, h4 1.06×, h5 1.0×, h6 0.9×

## [0.2.0] - 2025-01-27

### changed

- **document title**: now uses `std.title()` function instead of heading level 1
- **heading hierarchy**: headings now start at level 1 (previously level 2) since title is separate
  - adjusted sizes and applied condensed width (75% stretch) to all levels
- **footer layout**: redesigned with 2×2 grid, 9pt condensed font, and smart title truncation
  - title only appears on page 2+ and truncates to configurable line limit with ellipsis
  - improved spacing with tight leading (0.25em) and top alignment
  - handles complex content (colons, punctuation) via binary search algorithm
- updated documentation to reflect new heading structure

### fixed

- footer no longer pushes content or author information off page with long titles

## [0.1.0] - 2025-01-17

### added

- initial package structure with `typst.toml`
- `fd-doc` template with IBM Plex font family styling
- support for customizable document metadata (title, author, description, date)
- language and region configuration options
- code block styling using codly package
- custom heading styles (levels 1-6)
- page footer with page numbers and date
- package entry point (`lib.typ`) for easy importing
- examples directory with preview document

### dependencies

- codly 1.3.0
- codly-languages 0.1.10
