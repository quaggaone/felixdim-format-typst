# changelog

all notable changes to this project will be documented in this file.

the format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

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
