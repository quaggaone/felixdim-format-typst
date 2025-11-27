# felixdim format for Typst

this is a collection of personal Typst templates.

## installation

### as a local package

clone this repository into your local Typst packages directory on macOS:

```bash
git clone https://github.com/quaggaone/felixdim-format-typst.git ~/Library/Application\ Support/typst/packages/local/felixdim-format/x.y.z
```

for other platforms, see the [Typst packages documentation](https://github.com/typst/packages#local-packages).

## usage

### quick start with template

initialize a new project using the template:

```bash
typst init @local/felixdim-format:x.y.z my-project
cd my-project
```

this creates a new directory with a `main.typ` file pre-configured with the `fd-doc` template.

### basic usage

import the package and use the `fd-doc` template:

```typst
#import "@local/felixdim-format:x.y.z": fd-doc

#show: fd-doc.with(
  title: [your document title],
  author: "your name",
  description: [brief description],
  date: datetime.today(),
  lang: "en",
  region: "eu",
)

= introduction

your content goes here.

note: the template displays the title using the `title()` function (separate from headings), so you can start your content with level 1 headings (=) for main sections.
```

### requirements

the following fonts need to be installed on the system:

- IBM Plex Sans
- IBM Plex Sans Condensed
- IBM Plex Serif
- IBM Plex Mono
- IBM Plex Math

### options

special options for the `conf` function:

| key | type | description |
|:--- |:---- |:----------- |
| `title` | content | document metadata and on pages |
| `author` | string | document metadata and on pages |
| `description` | content | document metadata |
| `date` | valid Typst datetime | document metadata and on pages |
| `lang` | string of valid [ISO 639-1/2/3 language code](https://en.wikipedia.org/wiki/ISO_639) | influences text processing (eg. hyphenation, quotes) |
| `region` | string of valid [ISO 3166-1 alpha-2 region code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) | influences text processing pipeline (eg. decimal and thousands delimiters) |

## todo

- [ ] ADD support for checkboxes (`cheq` extension)
- [ ] IMPROVE layout/display for horizontal lines
- [ ] IMPROVE layout/display for blockquotes
- [ ] ADD formula numbering
- [ ] IMPROVE formula formatting (inline and block)
