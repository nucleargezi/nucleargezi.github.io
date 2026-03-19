#import "@preview/zebraw:0.6.1": *

#let zebraw = zebraw.with(inset: (top: 3pt, bottom: 3pt))

#let text-fonts = (
  (name: "Latin Modern Roman", covers: "latin-in-cjk"),
  "Noto Serif CJK SC",
  "Noto Color Emoji",
)
#let code-fonts = (
  "DejaVu Sans Mono",
)

#let body-size = 8pt
#let link-color = rgb("#ff9292")
#let code-bg = rgb("#f5f7fb")

// 标题字号
#let heading-size(level) = if level == 1 {
  22pt
} else if level == 2 {
  18pt
} else if level == 3 {
  15pt
} else if level == 4 {
  13pt
} else {
  11.5pt
}

#let heading-block(it) = {
  let spacing = if it.level == 1 {
    (above: 1.5em, below: 0.7em)
  } else {
    (above: 1.1em, below: 0.55em)
  }

  block(
    above: spacing.above,
    below: spacing.below,
  )[
    #set text(size: heading-size(it.level), weight: 700)
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
  set par(justify: true, leading: 0.72em) // 两端对齐 | 行距
  set list(indent: 1.25em)
  set enum(indent: 1.25em)
  set heading(numbering: "1.") // 标题编号

  show link: set text(fill: link-color)

  show heading: heading-block

  show raw: set text(font: code-fonts, size: 7.0pt)
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

  // 返回正文内容，让上面这些规则在正文渲染期间全部生效
  body
}

// 输出 frontmatter 元数据，供外部系统读取
// 设置文档标题
// 应用全局排版规则后再渲染正文
#let shared-template(
  title: "Untitled",
  desc: [No description],
  date: "1970-01-01",
  tags: (),
  body,
) = {
  [
    #metadata((
      title: title,
      description: desc,
      date: date,
      tags: tags,
    )) <frontmatter>
  ]

  set document(title: title)
  show: article-rules.with()

  body
}
