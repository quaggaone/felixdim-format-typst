# felixdim format for Typst

this is a collection of personal Typst templates.

## usage

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
