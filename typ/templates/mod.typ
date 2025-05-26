
#import "@preview/fletcher:0.5.7"
#import "target.typ": sys-is-html-target
#import "theme.typ": theme-frame
#import "@preview/shiroa:0.2.3": templates.get-label-disambiguator, plain-text

#let code-image = if sys-is-html-target {
  it => {
    theme-frame(theme => {
      set text(fill: theme.main-color)
      html.frame(it)
    })
  }
} else {
  it => it
}

/// Alternative resolves all heading as static link
///
/// - `elem`(content): The heading element to resolve
#let static-heading-link(elem) = context {
  let loc = here()
  let id = {
    "label-"
    str(get-label-disambiguator(loc, plain-text(elem)))
  }
  html.elem(
    "a",
    attrs: (
      "id": id,
      "data-typst-label": id,
      "href": "#" + id,
    ),
    "#",
  )
}

#let blog-tags = (
  programming: "Programming",
  software: "Software",
  software-engineering: "Software Engineering",
  tooling: "Tooling",
  linux: "Linux",
  dev-ops: "DevOps",
  compiler: "Compiler",
  music-theory: "Music Theory",
  misc: "Miscellaneous",
)

#let archive-tags = (
  blog-post: "Blog Post",
)
