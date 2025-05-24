
#import "@preview/zebraw:0.5.2": zebraw-init, zebraw
#import "@preview/shiroa:0.2.3": templates
#import templates: *
#import "mod.typ": *
#import "theme.typ": *
#import "supports-text.typ": plain-text

#let default-kind = "post"
// #let default-kind = "monthly"

#let build-kind = sys.inputs.at("build-kind", default: default-kind)

#let pdf-fonts = (
  "Libertinus Serif",
  "Source Han Serif SC",
)

#let code-font = (
  "DejaVu Sans Mono",
)

/// Creates an embedded block typst frame.
#let div-frame(content, attrs: (:), tag: "div") = html.elem(tag, html.frame(content), attrs: attrs)
#let span-frame = div-frame.with(tag: "span")
#let p-frame = div-frame.with(tag: "p")

// defaults
#let (
  style: theme-style,
  is-dark: is-dark-theme,
  is-light: is-light-theme,
  main-color: main-color,
  dash-color: dash-color,
  code-extra-colors: code-extra-colors,
) = default-theme

#let markup-rules(body) = {
  set text(font: pdf-fonts) if build-kind == "monthly"

  set text(16pt) if sys-is-html-target
  set text(fill: rgb("dfdfd6")) if is-dark-theme and sys-is-html-target
  show link: set text(fill: dash-color)

  body
}

#let equation-rules(body) = {
  show math.equation: set text(weight: 400)
  show math.equation.where(block: true): it => context if shiroa-sys-target() == "html" {
    theme-frame(
      tag: "p",
      theme => {
        set text(fill: theme.main-color)
        p-frame(attrs: ("class": "block-equation"), it)
      },
    )
  } else {
    it
  }
  show math.equation.where(block: false): it => context if shiroa-sys-target() == "html" {
    theme-frame(
      tag: "span",
      theme => {
        set text(fill: theme.main-color)
        span-frame(attrs: (class: "inline-equation"), it)
      },
    )
  } else {
    it
  }
  body
}

#let code-block-rules(body) = {
  let init-with-theme((code-extra-colors, is-dark)) = if is-dark {
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
    zebraw-init.with(
      // should vary by theme
      background-color: if code-extra-colors.bg != none {
        (code-extra-colors.bg, code-extra-colors.bg)
      },
      lang: false,
      numbering: false,
    )
  }

  /// HTML code block supported by zebraw.
  show: init-with-theme(default-theme)

  show raw: set text(font: code-font)
  show raw.where(block: true): it => context if shiroa-sys-target() == "paged" {
    set raw(theme: theme-style.code-theme) if theme-style.code-theme.len() > 0
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
    theme-frame(theme => {
      show: init-with-theme(theme)
      let code-extra-colors = theme.code-extra-colors
      set text(fill: code-extra-colors.fg) if code-extra-colors.fg != none
      set text(fill: if theme.is-dark { rgb("dfdfd6") } else { black }) if code-extra-colors.fg == none
      set raw(theme: theme-style.code-theme) if theme.style.code-theme.len() > 0
      set par(justify: false)
      zebraw(
        block-width: 100%,
        // line-width: 100%,
        wrap: false,
        it,
      )
    })
  }
  body
}

#let shared-template(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "2024-08-15",
  tags: (),
  kind: "post",
  body,
) = {
  let is-same-kind = build-kind == kind

  show: it => if is-same-kind {
    // set basic document metadata
    set document(
      author: ("Myriad-Dreamin",),
      title: title,
    )

    // markup setting
    show: markup-rules
    // math setting
    show: equation-rules
    // code block setting
    show: code-block-rules

    show: it => if sys-is-html-target {
      show footnote: it => context {
        let num = counter(footnote).get().at(0)
        link(label("footnote-" + str(num)), super(str(num)))
      }

      it
    } else {
      it
    }

    // Main body.
    set par(justify: true)
    it
  } else {
    it
  }

  show: it => if build-kind == "monthly" and is-same-kind {
    set page(numbering: "i")
    set heading(numbering: "1.1")
    it
  } else if build-kind == "monthly" and kind == "post" {
    set page(
      numbering: "1",
      header: context align(
        if calc.even(here().page()) { right } else { left },
        emph[
          #date -- #title
        ],
      ),
    ) if not sys-is-html-target
    set heading(offset: 1) if not sys-is-html-target // globally increase offset
    it
  } else {
    it
  }

  if build-kind == "monthly" and kind == "monthly" {
    align(
      center,
      {
        text(12pt, date)
        linebreak()
        strong(text(26pt, title))
        linebreak()
        text(16pt, desc)
      },
    )
    v(16pt)

    outline()
    pagebreak()
  }

  if build-kind == "monthly" and kind == "post" {
    show heading: set block(above: 0.2em, below: 0em)
    show heading: set text(size: 26pt)
    align(
      center,
      {
        text(12pt, date)
        linebreak()
        heading(numbering: none, title)
        counter(heading).step()
        linebreak()
        text(16pt, desc)
      },
    )
    v(16pt)
  }


  // todo monthly hack
  if kind == "monthly" or is-same-kind [
    #metadata((
      title: plain-text(title),
      author: "Myriad-Dreamin",
      description: plain-text(desc),
      date: date,
      tags: tags,
    )) <frontmatter>
  ]

  body

  context if is-same-kind and sys-is-html-target {
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
