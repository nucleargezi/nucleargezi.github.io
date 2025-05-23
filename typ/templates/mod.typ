
#import "@preview/fletcher:0.5.7"

#let sys-is-html-target = ("target" in dictionary(std))

#let code-image = if sys-is-html-target {
  it => {
    html.elem("div", html.frame(it), attrs: ("class": "code-image"))
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
