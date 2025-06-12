#import "/typ/templates/blog.typ": *
#show: main-en.with(
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

#figure(image("/public/shr/gui.png", alt: "Slint GUI"), caption: "Slint GUI (Absolute Path)")

#figure(image("../../public/shr/gui.png", alt: "Slint GUI"), caption: "Slint GUI (Relative Path)")
