#let conf(
  title: [],
  author: "",
  description: [],
  date: auto,
  // set date default to auto because datetime() cannot produce hours and minutes
  // auto is needed so PDF metadata has precise creation timecode
  lang: "en",
  region: "eu",
  doc
) = {
  // import packages
  import "@preview/codly:1.3.0": *
  import "@preview/codly-languages:0.1.10": *
  show: codly-init

  // import "@preview/cheq:0.3.0": checklist
  // show: checklist

  // package configs
  codly(
    languages: codly-languages,
    zebra-fill: none,
    radius: 0em,
    stroke: 0pt + luma(97%),
    fill: luma(97%),
    number-align: right + top,
    number-placement: "outside",
    lang-outset: (x: 0.45em, y: -0.13em),
    lang-radius: 0em,
  )

  // document setup
  // convert structured date dictionary to datetime object if needed
  let doc-date = if date == auto {
    auto
  } else if type(date) == dictionary {
    datetime(year: date.year, month: date.month, day: date.day)
  } else {
    date
  }

  set document(
    title: title,
    author: author,
    description: description,
    date: doc-date
  )
  set page(
    margin: (left: 1.5cm, right: 1.5cm, top: 1.5cm, bottom: 1.5cm),
    number-align: right,
    footer-descent: 20%,
    footer: context [
      #let footer-font-size = 9pt
      #let max-title-lines = 1
      #let leading-em = 0.25em  // tight line spacing for compact footer
      #let leading = footer-font-size * (leading-em / 1em)  // convert em to pt for calculations
      // use ascender/descender edges for accurate height measurements
      #set text(size: footer-font-size, stretch: 75%, top-edge: "ascender", bottom-edge: "descender")
      #set par(leading: leading-em, spacing: 0pt)
      #set block(above: 0pt, below: 0pt, spacing: 0pt)
      #grid(
        columns: (1fr, 3fr),
        rows: (auto, auto),
        row-gutter: 1pt,
        align: top + left,

        // row 1, column 1: page number
        [#counter(page).display("1 / 1", both: true)],

        // row 1, column 2: title (page 2+, max lines with ellipsis)
        align(top)[#if counter(page).get().at(0) > 1 {
          // layout() provides actual grid cell width needed for accurate text wrapping measurements
          layout(size => {
            let available-width = size.width

            // title truncation strategy:
            // 1. measure reference height for max-title-lines (configurable)
            // 2. measure actual title height
            // 3. if title too tall, extract plain text and binary search for max length
            // 4. binary search ensures title + "..." fits exactly within height limit

            // build reference text to measure target height
            // creates N lines of dummy text to establish height limit for title
            let reference-parts = ()
            for i in range(max-title-lines) {
              reference-parts.push("Line " + str(i + 1))
            }
            let reference-text = reference-parts.join("\n")
            let reference-height = measure(  // target height limit based on max-title-lines
              block(width: available-width, text(size: footer-font-size, stretch: 75%, reference-text))
            ).height

            let title-text = document.title

            // measure full title
            let measured = measure(  // actual title height when rendered
              block(width: available-width, text(size: footer-font-size, stretch: 75%, title-text))
            ).height

            if measured > reference-height {
              // need to truncate - extract plain text from content
              // extract plain text from typst content using repr()
              // repr() returns different formats depending on content complexity:
              // - simple: [text] -> just remove brackets
              // - complex (with punctuation): sequence([part1], [part2], ...) -> extract all parts
              let title-str = if type(title-text) == str {  // plain text extracted from content
                title-text
              } else {
                // for content, use repr() and handle sequence() format
                let r = repr(title-text)

                // check if it's a sequence (complex content with multiple parts)
                if r.starts-with("sequence(") {
                  // extract all content blocks between [...]
                  let result = ""
                  let parts = r.split("[")
                  for part in parts {
                    if part.contains("]") {
                      let content = part.split("]").at(0)
                      result = result + content
                    }
                  }
                  result
                } else if r.starts-with("[") and r.ends-with("]") {
                  // simple content - just remove outer brackets
                  r.slice(1, -1)
                } else {
                  r
                }
              }

              // use binary search to efficiently find maximum characters that fit
              // avoids testing every possible length (O(log n) vs O(n))
              // measures title + "..." to ensure ellipsis fits within height limit
              let left = 0
              let right = title-str.len()
              let result = title-str.slice(0, calc.min(20, title-str.len())) + "..."  // fallback if search fails

              // binary search to find maximum length that fits (including the "...")
              while left < right {
                let mid = calc.floor((left + right + 1) / 2)
                let test-str = title-str.slice(0, mid) + "..."
                let test-height = measure(
                  block(width: available-width, text(size: footer-font-size, stretch: 75%, test-str))
                ).height

                if test-height <= reference-height {
                  result = test-str
                  left = mid
                } else {
                  right = mid - 1
                }
              }

              block(width: 100%, result)
            } else {
              block(width: 100%, title-text)
            }
          })
        }],

        // row 2, column 1: date
        [#if doc-date == auto {
          datetime.today().display("[year]-[month]-[day], [weekday repr:short]")
        } else {
          doc-date.display("[year]-[month]-[day], [weekday repr:short]")
        }],

        // row 2, column 2: author
        [#for (value) in document.author {value}],
      )
    ],
    background: context [
      // page-wise TOC with lines in right margin
      #let toc-color-inactive = luma(85%)
      #let toc-color-active = luma(30%)
      #let toc-line-spacing = 0.1cm
      #let max-line-length = 0.9cm
      #let line-decrement = 0.15cm

      // get all headings in document
      #let all-headings = query(selector(heading))
      #let current-page = here().page()

      // filter headings up to level 6
      #let toc-headings = all-headings.filter(h => h.level <= 6)

      // get first heading on current page
      #let headings-on-page = toc-headings.filter(h => h.location().page() == current-page)
      #let first-heading-on-page = if headings-on-page.len() > 0 { headings-on-page.first() } else { none }

      // resolve page.margin from relative length to absolute value
      // relative lengths have .length (absolute) and .ratio (percentage) components
      // see: https://stackoverflow.com/questions/77690878/get-current-page-margins-in-typst#78185552
      #let margin-right = if page.margin == auto {
        calc.min(page.width, page.height) * 2.5 / 21
      } else {
        page.margin.length + page.margin.ratio * page.width
      }

      // resolve top margin the same way as right margin
      #let margin-top = if page.margin == auto {
        calc.min(page.width, page.height) * 2.5 / 21
      } else {
        page.margin.length + page.margin.ratio * page.height
      }

      // check if page starts with a heading by examining the position of the first heading
      // if the first heading's y-position is at/near the top margin, page starts with heading
      #let page-starts-with-heading = if first-heading-on-page != none {
        let heading-pos = first-heading-on-page.location().position()
        // check if heading is within a small threshold of the top margin (e.g., 0.5cm tolerance)
        calc.abs(heading-pos.y - margin-top) < 0.5cm
      } else {
        false
      }

      // get previous heading and only mark it active if page doesn't start with a heading
      #let headings-before = query(selector(heading).before(here()))
      #let active-headings = if headings-before.len() > 0 and not page-starts-with-heading {
        (headings-before.last(),)
      } else {
        ()
      }

      #place(
        right + top,
        dx: -1 * (margin-right - max-line-length) / 2,
        dy: margin-top,
        stack(
          dir: ttb,
          spacing: toc-line-spacing,
          ..toc-headings.map(h => {
            let line-length = max-line-length - (h.level - 1) * line-decrement

            // heading is active if it's on current page OR is the previous heading (if page doesn't start with heading)
            let is-on-page = h.location().page() == current-page
            let is-active = is-on-page or active-headings.contains(h)

            let line-color = if is-active { toc-color-active } else { toc-color-inactive }

            line(
              length: line-length,
              stroke: 1pt + line-color
            )
          })
        )
      )
    ]
  )

  // text related setup
  let font-size = 11pt
  set text(
    lang: lang,
    region: region,
    font: "IBM Plex Sans",
    size: font-size
  )

  show math.equation: set text(font: "IBM Plex Math")

  show raw: set text(
    font: "IBM Plex Mono"
  )

  show raw.where(
    block: false
  ): set text(
    size: 1.2em
  )

  show raw.where(
    block: false
  ): it => box(rect(
    fill: luma(93%),
    inset: (x: 0.15em, y: 0em),
    outset: (x: -0.05em, y: 0.2em),
    it
  ))

  show std.title: set text(
    size: 2.2 * font-size,
    font: "IBM Plex Sans",
    stretch: 75%,
    weight: "bold"
  )

  show heading: set text(
    stretch: 75%
  )

  show heading.where(
    level: 1
  ): set text(
    size: 1.75 * font-size,
    weight: "bold"
  )
  show heading.where(
    level: 2
  ): set text(
    size: 1.4 * font-size,
    weight: "bold"
  )
  show heading.where(
    level: 3
  ): set text(
    size: 1.12 * font-size,
    weight: "bold"
  )
  show heading.where(
    level: 4
  ): set text(
    size: 1.06 * font-size,
    font: "IBM Plex Sans Cond SmBld",
    weight: "semibold",
    style: "normal"
  )
  show heading.where(
    level: 5
  ): set text(
    size: 1.0 * font-size,
    font: "IBM Plex Sans Cond SmBld",
    weight: "semibold",
    style: "normal"
  )
  show heading.where(
    level: 6
  ): set text(
    size: 0.9 * font-size,
    font: "IBM Plex Sans Cond Medm",
    weight: "medium",
    style: "normal"
  )
  show heading.where(
    level: 4
  ).or(
    heading.where(
      level: 5
    )
  ).or(
    heading.where(
      level: 6
    )
  ): text

  show heading: set block(
    above: 1.5em,
    below: 1.1 * font-size  // ~12pt spacing after headings (maintains previous value)
  )

  set par(
    spacing: 1em + 6pt,
    justify: true,
  )

  set list(
    marker: ([‣], [•])
  )
  /* #set list(
    marker: ([‣], [•], [–], [▷], [◦], [#set text(font: "Times New Roman");▪︎▫⬝])
  ) */

  show figure.caption: set align(left)
  show figure: set block(width: 100%)

  // table settings
  let table-stroke-outer = 1.25pt
  let table-stroke-header = 0.75pt

  set table(
    inset: (x: 0.5em, y: 0.4em),
    align: left,
    stroke: (x, y) => (
      top: if y == 0 { table-stroke-outer } else if y == 1 { table-stroke-header } else if y > 1 { 0pt },
      bottom: table-stroke-outer,
      x: none,
    )
  )

  show table: it => {
    set text(stretch: 75%)

    show table.cell: cell => {
      // semibold weight for header row (row 0) and first column (col 0)
      if cell.y == 0 or cell.x == 0 {
        set text(font: "IBM Plex Sans Cond SmBld", weight: "semibold")
        cell
      } else {
        cell
      }
    }

    it
  }

  // outline settings
  show outline: set heading(
    // numbering: "1.1", // enables numbering for items manually added to the outline
    outlined: true
  )
  set outline.entry(
    fill: line(length: 100%, stroke: rgb("#00000050"))
  )


  // content
  std.title()

  doc
}
