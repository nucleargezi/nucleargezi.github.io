#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "FPS Learn Memo 1",
  desc: [形式幂级数学习笔记1],
  date: "2025-12-16",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.rec
  ),
  show-outline: true,
)

#set text(size: 8pt)

#let msk = "■";
#let HL(s) = text(size: 10pt)[*#s*]

= 多项式 | 形式幂级数 2
