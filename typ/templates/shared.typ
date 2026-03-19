#import "@preview/zebraw:0.6.1": *

// 为代码块增加斑马纹高亮时使用的默认配置。
#let zebraw = zebraw.with(inset: (top: 3pt, bottom: 3pt))

// 正文字体
#let text-fonts = (
  (name: "Latin Modern Roman", covers: "latin-in-cjk"),
  "Noto Serif CJK SC",
  "Noto Color Emoji",
)

// 代码字体
#let code-fonts = (
  "DejaVu Sans Mono",
)

#let body-size = 10.5pt
#let link-color = rgb("#ff9292")
#let code-bg = rgb("#f5f7fb")

// 按标题层级返回字号，保证不同层级之间有稳定的视觉梯度。
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

// 统一标题块的上下留白和字重。
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

// 通用块级代码容器。
// 普通代码块和带 `zebraw` 的代码块都复用这一层，
// 这样背景、圆角、内边距和上下间距只需要维护一份。
// #let code-block-frame(body) = block(
// width: 100%,
// above: 1em,
// below: 1em,
// fill: code-bg,
// inset: (x: 10pt, y: 9pt),
// radius: 6pt,
// )[
//   #set par(justify: false)
//   #body
// ]

// 文章正文的基础排版规则。
// 你后续如果想调整博客观感，通常会从这几类配置入手：
// - 页面：版心宽度、页边距、内容密度。
// - 正文：字体、字号、行距、两端对齐。
// - 结构元素：标题、列表、编号。
// - 特殊内容：链接、行内代码、代码块、公式。
#let article-rules(body, lang: none, region: none) = {
  // 页面尺寸和留白。
  // `width` 控制正文的可读宽度；更大更像网页，较小更像书页。
  // `margin` 控制页面四周空白；如果想要更透气或更紧凑，可以直接调这里。
  // `height: auto` 表示页面高度随内容增长，适合长文章排版。
  set page(
    width: 540pt,
    height: auto,
    margin: (x: 24pt, y: 20pt),
  )

  // 正文的默认字体和字号。
  // `text-fonts` 是字体回退链：西文优先，中文与 emoji 在后面兜底。
  // `body-size` 是整篇文章的基准字号，标题和代码一般会围绕它做相对调整。
  set text(font: text-fonts, size: body-size)

  // 可选的语言和地区信息。
  // 这会影响 Typst 对文本的语言相关处理，比如断词或某些地区化排版细节。
  // 只有模板调用方传入了 `lang` / `region` 时才启用。
  set text(lang: lang) if lang != none
  set text(region: region) if region != none

  // 段落基础样式。
  // `justify: true` 会让正文两端对齐，观感更接近传统排版。
  // 如果你想要更现代、更像网页文章的松弛布局，可以改成 `false`。
  // `leading` 是行距，越大越疏朗，越小越紧凑。
  set par(justify: true, leading: 0.72em)

  // 列表缩进。
  // 无序列表和有序列表共用同一缩进，让整体层级关系更一致。
  // 如果条目文字较长，适当增加缩进通常会更易读。
  set list(indent: 1.25em)
  set enum(indent: 1.25em)

  // 标题编号格式。
  // `"1."` 会产生类似 `1.`, `1.1.`, `1.1.1.` 的层级编号。
  // 如果你不想显示编号，可以删掉这一行；如果想换风格，可以改 numbering 模式。
  set heading(numbering: "1.")

  // 链接样式。
  // 当前只给链接着色，不添加下划线，因此风格会比较克制。
  // 想增强识别度时，通常在这里继续加 underline、边框或 hover 风格。
  show link: set text(fill: link-color)

  // 标题渲染交给 `heading-block` 统一处理。
  // 这样标题字号、字重和上下留白都集中在一个函数里维护。
  show heading: heading-block

  // 所有代码内容的基础样式。
  // 这条规则同时作用于行内代码和代码块；后续更具体的 `show raw.where(...)`
  // 会在此基础上继续叠加样式。
  // 这里把字号设得比较小，适合代码密度较高的文章；如果代码看起来偏挤，可以先调大它。
  show raw: set text(font: code-fonts, size: 7.0pt)

  // 行内代码样式。
  // 使用浅背景、轻微内边距和圆角，让代码片段从正文中被识别出来，
  // 但又不会像块级代码那样打断阅读节奏。
  show raw.where(block: false): it => box(
    fill: code-bg,
    inset: (x: 4pt, y: 2pt),
    radius: 3pt,
  )[
    #it
  ]
  // show raw.where(block: true): it => code-block-frame(it)

  // C++ 代码块的专用增强样式。
  // 这条规则只匹配 ````cpp ... ```` 这类块级代码，
  // `zebraw` 只负责代码行内部的排版；外层容器仍然复用通用块级代码样式。
  // - 给其他语言也启用行号：复制这条规则并改 `lang`
  // - 关闭行号：把 `numbering: true` 改掉或移除
  // - 统一所有语言都加斑马纹：可以改成更通用的 block raw 规则
  show raw.where(block: true): it => zebraw(
    background-color: code-bg,
    numbering: true,
    inset: (x: 10pt, y: 9pt), // x 援交半径 y 行间距
    it,
  )

  // 块级公式样式。
  // 目前只做两件事：增加上下留白，并让公式水平居中。
  // 如果之后想做论文风格的公式编号、公式框或更大的间距，这里就是入口。
  show math.equation.where(block: true): it => block(
    above: 1em,
    below: 1em,
  )[
    #align(center, it)
  ]

  // 返回正文内容，让上面这些规则在正文渲染期间全部生效。
  body
}

// 通用文章模板：
// 1. 输出 frontmatter 元数据，供外部系统读取。
// 2. 设置文档标题。
// 3. 应用全局排版规则后再渲染正文。
#let shared-template(
  title: "Untitled",
  desc: [No description],
  date: "1970-01-01",
  tags: (),
  lang: none,
  region: none,
  body,
) = {
  [
    #metadata((
      title: title,
      description: desc,
      date: date,
      tags: tags,
      ..if lang != none { (lang: lang) },
      ..if region != none { (region: region) },
    )) <frontmatter>
  ]

  set document(title: title)
  show: article-rules.with(lang: lang, region: region)

  body
}
