
#import "@preview/fletcher:0.5.7"
#import "target.typ": sys-is-html-target
#import "theme.typ": theme-frame

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
