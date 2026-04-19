// preset sizes:
//   "regular" — 57 × 190 mm (standard Leitz/Avery binder spine)
//   "narrow"  — 32 × 190 mm (narrow spine)
// custom: set width/height directly (overrides size preset)

#let conf(
  category: none,
  number: none,
  content: (),
  logo: none,
  accent: rgb("#1a3a6e"),
  font: "IBM Plex Sans",
  mono-font: "IBM Plex Mono",
  size: "regular",
  width: none,
  height: none,
  bullets: false,
  doc
) = {
  // resolve dimensions: explicit width/height override the preset
  let presets = (
    regular: (width: 57mm, height: 190mm),
    narrow:  (width: 32mm, height: 190mm),
  )
  let preset = presets.at(size, default: presets.regular)
  let width  = if width  != none { width  } else { preset.width  }
  let height = if height != none { height } else { preset.height }

  // strip heights are fixed absolute values — independent of label dimensions
  let top-strip-height    = 20mm
  let bottom-strip-height = 12mm

  // inner-padding: gap between last ruled line and bottom strip
  let inner-padding = 4mm

  // strip layout: uniform padding on all sides, slightly tighter gap between the two lines
  let strip-padding  = top-strip-height * 0.22
  let strip-line-gap = strip-padding * 0.55

  // cell-height is the available vertical space per line inside the strip
  let cell-height = (top-strip-height - 2 * strip-padding - strip-line-gap) / 2

  // ruled line parameters
  let line-height       = 8mm
  let bullet-width      = 8mm
  let line-left-margin  = if bullets { bullet-width } else { 3mm }
  let indent-per-depth  = 4mm
  let line-stroke       = 0.35pt + luma(70%)
  let content-font-size = line-height * 0.44
  let num-lines = calc.floor(
    (height - top-strip-height - bottom-strip-height - inner-padding) / line-height
  )

  // validate content
  assert(type(content) == array,
    message: "fd-binder-spine: `content` must be an array, e.g. content: ([Item 1], [Item 2])"
  )
  assert(content.all(item => type(item) == type([])),
    message: "fd-binder-spine: every item in `content` must be a content value, e.g. [Item 1]"
  )

  // pick white or black for text on the accent strip based on perceived luminance
  // uses standard luminance weights on the RGB components (assumed to be in rgb space)
  let on-accent = {
    let (r, g, b) = color.components(accent, alpha: false)
    if r * 0.299 + g * 0.587 + b * 0.114 > 50% { black } else { white }
  }

  set page(
    width:  width,
    height: height,
    // no left/right margin — lines and content extend to the page edges
    margin: (left: 0pt, right: 0pt, top: top-strip-height, bottom: bottom-strip-height + inner-padding),
    background: context [
      // derive strip font sizes — measure() requires layout context
      // each font measured independently so cap heights fill the cell regardless of font metrics
      #let category-cap-height = measure(
        text(size: 10pt, font: font, top-edge: "cap-height", bottom-edge: "baseline", "A")
      ).height
      #let number-cap-height = measure(
        text(size: 10pt, font: mono-font, top-edge: "cap-height", bottom-edge: "baseline", "A")
      ).height
      #let category-font-size = 10pt * (cell-height / category-cap-height)
      #let number-font-size   = 10pt * (cell-height / number-cap-height)

      // top strip background
      #place(top, rect(width: 100%, height: top-strip-height, fill: accent))
      // line 1: category — top left, uppercase, semibold, fills cell height
      #if category != none {
        place(top + left, dx: strip-padding, dy: strip-padding,
          text(
            size:        category-font-size,
            weight:      "semibold",
            fill:        on-accent,
            stretch:     75%,
            font:        font,
            top-edge:    "cap-height",
            bottom-edge: "baseline",
            upper(category)
          )
        )
      }
      // line 2: number — below category, right-aligned, monospace, lighter
      #if number != none {
        place(top + right, dx: -strip-padding, dy: strip-padding + cell-height + strip-line-gap,
          text(
            size:        number-font-size,
            weight:      "regular",
            fill:        on-accent,
            stretch:     75%,
            font:        mono-font,
            top-edge:    "cap-height",
            bottom-edge: "baseline",
            upper(str(number))
          )
        )
      }
      // ruled lines: from line-left-margin to right page edge, every 8mm from strip bottom
      #for i in range(1, num-lines + 1) {
        place(top + left,
          dx: line-left-margin,
          dy: top-strip-height + i * line-height,
          line(length: width - line-left-margin, stroke: line-stroke)
        )
      }
      // bottom strip
      #place(bottom, rect(width: 100%, height: bottom-strip-height, fill: accent))
      // logo: centered in the bottom strip, user is responsible for color
      #if logo != none {
        place(bottom + center,
          dy: -(bottom-strip-height - strip-padding) / 2,
          box(
            height: bottom-strip-height - 2 * strip-padding,
            logo
          )
        )
      }
    ]
  )

  set text(font: font, stretch: 75%)

  // body: one row per content item, overlaid on the background ruled lines
  if content.len() > 0 {
    set block(above: 0pt, below: 0pt)
    set par(spacing: 0pt)

    stack(
      dir: ttb,
      spacing: 0pt,
      ..content.map(item => if bullets {
        grid(
          columns: (bullet-width, 1fr),
          rows:    (line-height,),
          align(center + horizon,
            text(size: bullet-width * 0.30, fill: luma(20%), "▶")
          ),
          align(left + horizon, pad(top: 0.7mm,
            text(size: content-font-size, weight: "medium", item)
          )),
        )
      } else {
        box(
          width: 100%,
          height: line-height,
          pad(left: line-left-margin, top: 0.7mm,
            align(left + horizon,
              text(size: content-font-size, weight: "medium", item)
            )
          )
        )
      })
    )
  }

  doc
}
