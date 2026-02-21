#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Group Theory",
  desc: [群论学习笔记(施工中)],
  date: "2026-02-01",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.rec,
  ),
  show-outline: true,
)

#show raw.where(block: true, lang: "cpp"): it => zebraw(
  numbering: true,
  it,
)

#set text(size: 8pt)

= Group Theory
