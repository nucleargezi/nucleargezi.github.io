#import "/typ/templates/blog.typ": *
#show: main.with(
  title: "Typst Syntax",
  desc: [List of Typst Syntax, for rendering tests.],
  date: "2025-05-27",
  tags: (
    blog-tags.programming,
    blog-tags.typst,
  ),
)

= Raw Blocks

This is an inline raw block `class T`.

This is an inline raw block ```js class T```.

This is a long inline raw block ```js class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {};```.

Js syntax highlight are handled by syntect:

```js
class T {};
```

Typst syntax hightlight are specially handled internally:

```typ
#let f(x) = x;
```

= Images

#let parse-env(data) = {
  let lines = data.split("\n").map(it => it.trim()).filter(it => it != "" and not it.starts-with("#"))
  let env = (:)

  lines
    .map(line => {
      let matched = line.match(regex("^([^=]+)=(?:\"([^\"]*)\"|(.*))$"))
      let (key, v1, v2) = matched.captures
      (key, v1 + v2)
    })
    .to-dict()
}

// todo: what if I would like use other configuration like `.env-production`
#let env-data = parse-env(read("/.env"))

#let url-base = env-data.at("URL_BASE", default: "")
#if not url-base.ends-with("/") {
  url-base = url-base + "/"
}
#let resolve(path) = (path.replace("../../public/", url-base).replace("/public/", url-base))

#show image: it => {
  html.elem(
    "img",
    attrs: (src: resolve(it.source), style: "width: 33%; display: block; margin: auto;"),
  )
}

#image("../../public/favicon.svg")
