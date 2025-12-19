#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "FPS Learn Note",
  desc: [形式幂级数的转换],
  date: "2025-12-19",
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

= 多项式 | 形式幂级数 的转换

== T

=== 二项式定理
$(x+y)^n = sum_(0<=i<=n) binom(n, i)x^i y^(n-i)$

$binom(n, i)$ 是二项系数，有时记作 $C_n^i$ 。

对于 $i<0$ 或 $i>n$ 有 $binom(n, i) = 0$ ，因此求和范围随意，写成 $sum_(i=0)^infinity$ 也可以。

=== 等比数列和

对 $r!=1$ ，有 $sum_(i=0)^(n-1)r^i = (1-r^n)/(1-r)$ 成立。

=== log

$log(1 - t) = -sum_(i >= 1) t^i / i -> log(1 - x^b) = -sum_(i>=1) x^(i b) / i$

