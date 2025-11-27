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
  set document(
    title: title,
    author: author,
    description: description,
    date: date
  )
  set page(
    margin: 1.5cm,
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
        [#if date == auto {
          datetime.today().display("[year]-[month]-[day], [weekday repr:short]")
        } else {
          date.display("[year]-[month]-[day], [weekday repr:short]")
        }],

        // row 2, column 2: author
        [#for (value) in document.author {value}],
      )
    ]
  )

  // text related setup
  set text(
    lang: lang,
    region: region,
    font: "IBM Plex Sans",
    size: 11pt
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
    size: 1.4em,
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
    size: 1.25em,
    weight: "bold"
  )
  show heading.where(
    level: 2
  ): set text(
    size: 1.1875em,
    weight: "bold"
  )
  show heading.where(
    level: 3
  ): set text(
    size: 1.125em,
    weight: "bold"
  )
  show heading.where(
    level: 4
  ): set text(
    size: 1.0625em,
    font: "IBM Plex Sans Cond SmBld",
    weight: "semibold",
    style: "normal"
  )
  show heading.where(
    level: 5
  ): set text(
    size: 1em,
    font: "IBM Plex Sans Cond SmBld",
    weight: "semibold",
    style: "normal"
  )
  show heading.where(
    level: 6
  ): set text(
    size: 0.9em,
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
    below: 12pt
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
