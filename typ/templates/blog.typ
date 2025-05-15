
#import "@preview/zebraw:0.5.2": zebraw-init, zebraw
#import "@preview/shiroa:0.2.3": templates
#import templates: *
#import "mod.typ": *

#let code-font = (
  "DejaVu Sans Mono",
)

/// Creates an embedded block typst frame.
#let div-frame(content, attrs: (:), tag: "div") = html.elem(tag, html.frame(content), attrs: attrs)
#let span-frame = div-frame.with(tag: "span")
#let p-frame = div-frame.with(tag: "p")

// Theme (Colors)
#let (
  style: theme-style,
  is-dark: is-dark-theme,
  is-light: is-light-theme,
  main-color: main-color,
  dash-color: dash-color,
  code-extra-colors: code-extra-colors,
) = book-theme-from(toml("theme-style.toml"), xml: it => xml(it), target: "web-ayu")

#let main(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "2024-08-15",
  body,
) = {
  // set basic document metadata
  set document(
    author: ("Myriad-Dreamin",),
    title: title,
  )

  set text(18pt) if sys-is-html-target

  // link setting
  show link: set text(fill: dash-color)

  // math setting
  show math.equation: set text(weight: 400)
  show math.equation.where(block: true): it => context if shiroa-sys-target() == "html" {
    p-frame(attrs: ("class": "block-equation"), it)
  } else {
    it
  }
  show math.equation.where(block: false): it => context if shiroa-sys-target() == "html" {
    span-frame(attrs: (class: "inline-equation"), it)
  } else {
    it
  }

  set text(fill: rgb("dfdfd6")) if is-dark-theme

  /// HTML code block supported by zebraw.
  show: if is-dark-theme {
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      highlight-color: rgb("#3d59a1"),
      comment-color: rgb("#394b70"),
      lang-color: rgb("#3d59a1"),
      lang: false,
      numbering: false,
    )
  } else {
    zebraw-init.with(lang: false, numbering: false)
  }

  // code block setting
  set raw(theme: theme-style.code-theme) if theme-style.code-theme.len() > 0
  show raw: set text(font: code-font)
  show raw.where(block: true): it => context if shiroa-sys-target() == "paged" {
    rect(
      width: 100%,
      inset: (x: 4pt, y: 5pt),
      radius: 4pt,
      fill: code-extra-colors.bg,
      [
        #set text(fill: code-extra-colors.fg) if code-extra-colors.fg != none
        #set par(justify: false)
        // #place(right, text(luma(110), it.lang))
        #it
      ],
    )
  } else {
    set text(fill: code-extra-colors.fg) if code-extra-colors.fg != none
    set par(justify: false)
    zebraw(
      block-width: 100%,
      // line-width: 100%,
      wrap: false,
      it,
    )
  }

  show: it => if sys-is-html-target {
    show footnote: it => context {
      let num = counter(footnote).get().at(0)
      link(label("footnote-" + str(num)), super(str(num)))
    }

    it
  }

  [
    #metadata((
      title: title,
      author: "Myriad-Dreamin",
      desc: desc,
      date: date,
    )) <frontmatter>
  ]

  // Main body.
  set par(justify: true)

  body
  context if sys-is-html-target {
    query(footnote)
      .enumerate()
      .map(((idx, it)) => {
        enum.item[
          #html.elem(
            "div",
            attrs: ("data-typst-label": "footnote-" + str(idx + 1)),
            it.body,
          )
        ]
      })
      .join()
  }
}
