
#import "@preview/fletcher:0.5.7"

#let sys-is-html-target = ("target" in dictionary(std))

#let code-image = if sys-is-html-target {
  it => {
    html.elem("div", html.frame(it), attrs: ("class": "code-image"))
  }
} else {
  it => it
}
