#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Group Theory",
  desc: [群论学习笔记 施工中],
  date: "2026-02-03",
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

= Group

一个 Group 就是满足以下条件的二元组 $(G, *)$ , $G$ 是集合, $*$ 是集合上的二元运算
- 封闭性: $forall a, b in G, a * b in G$
- 结合率: $forall a, b, c in G, (a * b) * c = a * (b * c)$
- 单位元: $exists e in G, forall a in G , a * e = e * a = a$
- 元素存在逆元 $forall a in G, a * a^(-1) = a^(-1) * a = e$

算法竞赛中常用树状数组维护的那类信息就是 Group , 本文并不会讨论信息维护之类的内容, 更多是和计数相关

= Cyclic Group
