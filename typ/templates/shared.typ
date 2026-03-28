#import "@preview/zebraw:0.6.1": *

#let zebraw = zebraw.with(inset: (top: 3pt, bottom: 3pt))

#let text-fonts = (
  (name: "Latin Modern Roman", covers: "latin-in-cjk"),
  "Noto Serif CJK SC",
  "Noto Color Emoji",
)
#let code-fonts = (
  "Fira Code",
  // "DejaVu Sans Mono",
)

#let body-size = 7pt
#let link-color = rgb("#ff5757")
#let code-bg = rgb("#f5f7fb")

// 标题字号
#let heading-size(level) = if level == 1 {
  13pt
} else if level == 2 {
  12pt
} else if level == 3 {
  11pt
} else if level == 4 {
  10pt
} else {
  9.5pt
}

#let heading-block(it) = {
  let spacing = if it.level == 1 {
    (above: 1.5em, below: 1em)
  } else {
    (above: 1.1em, below: 1.1em)
  }

  block(
    above: spacing.above,
    below: spacing.below,
  )[
    #set text(size: heading-size(it.level), weight: 700, style: "italic")
    #it
  ]
}

#let article-rules(body, lang: none, region: none) = {
  set page(
    width: 540pt,
    height: auto, // 不分页
    margin: (x: 24pt, y: 20pt),
  )

  set text(font: text-fonts, size: body-size)
  set par(justify: true, leading: 0.62em) // 两端对齐 | 行距
  set list(indent: 1.25em)
  set enum(indent: 1.25em)
  // set heading(numbering: "1.") // 标题编号

  show link: set text(fill: link-color)

  show heading: heading-block

  show raw: set text(font: code-fonts, size: 6.7pt)
  show raw.where(block: false): it => box(
    fill: code-bg,
    inset: (x: 2pt, y: 1pt),
    // radius: 3pt,
  )[
    #it
  ]
  show raw.where(block: true): it => zebraw(
    lang: false,
    background-color: code-bg,
    numbering: true,
    inset: (x: 10pt, y: 9pt), // x 援交半径 y 行间距
    it,
  )

  show math.equation.where(block: true): it => block(
    above: 1em,
    below: 1em,
  )[
    #align(center, it)
  ]

  body
}

#let shared-template(
  title: "Untitled",
  desc: [No description],
  date: "1970-01-01",
  tags: (),
  category: "",
  body,
) = {
  [
    #metadata((
      title: title,
      description: desc,
      date: date,
      tags: tags,
      category: category,
    )) <frontmatter>
  ]

  set document(title: title)
  show: article-rules.with()

  body
}
