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
      #let max-title-lines = 2
      #let leading-em = 0.25em  // Space between lines
      #let leading = footer-font-size * (leading-em / 1em)  // Convert em to pt
      #set text(size: footer-font-size, stretch: 75%, top-edge: "ascender", bottom-edge: "descender")
      #set par(leading: leading-em, spacing: 0pt)
      #set block(above: 0pt, below: 0pt, spacing: 0pt)
      #grid(
        columns: (1fr, 3fr),
        rows: (auto, auto),
        row-gutter: 1pt,
        align: top + left,

        // Row 1, Column 1: Page number
        [#counter(page).display("1 / 1", both: true)],

        // Row 1, Column 2: Title (page 2+, max 2 lines with ellipsis)
        align(top)[#if counter(page).get().at(0) > 1 {
          layout(size => {
            let title-text = document.title
            let available-width = size.width  // Use full width from layout

            // Measure a reference 2-line text to get the actual height
            let reference-text = "Line one\nLine two"
            let reference-height = measure(
              block(width: available-width, text(size: footer-font-size, stretch: 75%, reference-text))
            ).height

            // Measure actual title
            let measured = measure(
              block(width: available-width, text(size: footer-font-size, stretch: 75%, title-text))
            )

            if measured.height > reference-height {
              // Clip title and add ellipsis with proper positioning
              block(width: 100%, height: reference-height, clip: true, title-text + [ ...])
            } else {
              block(width: 100%, title-text)
            }
          })
        }],

        // Row 2, Column 1: Date
        [#if date == auto {
          datetime.today().display("[year]-[month]-[day], [weekday repr:short]")
        } else {
          date.display("[year]-[month]-[day], [weekday repr:short]")
        }],

        // Row 2, Column 2: Author
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
