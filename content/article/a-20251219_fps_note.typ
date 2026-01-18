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
#let HL(s) = text(size: 9pt)[*#s*]
#let tab = text[#h(8pt)]
#let endl = linebreak()

= 多项式 | 形式幂级数 简便查询笔记

== T

=== 二项式定理
$ (x+y)^n = sum_(0<=i<=n) binom(n, i)x^i y^(n-i) $

$binom(n, i)$ 是二项系数，有时记作 $C_n^i$ 。

对于 $i<0$ 或 $i>n$ 有 $binom(n, i) = 0$ ，因此求和范围随意，写成 $sum_(i=0)^infinity$ 也可以。

=== 等比数列和

对 $x!=1$ ，有 
$ 
  sum_(i=0)^(n-1)x^i = (1-x^n)/(1-x) 
$

$ 
  sum_(i=0)^infinity x^i = 1/(1-x) 
$

对于形式幂级数 
$ 
  sum_(i=0)^infinity f^i = 1/(1-f) tab [x^0]f = 0 
$

=== ln(1-t)

$ log(1 - t) = -sum_(i >= 1) t^i / i $ 
$ log(1 - x^b) = -sum_(i>=1) x^(i b) / i tab (b>=1) $

=== $e^(a x)$

$ sum_i^infinity (a x)^i/i! = e^(a x) $

=== 二项式反演
记 $f_i$ 为恰好 $i$ 个， $g_i$ 为至少 $i$ 个，有
$
  g_k = sum_(i>=k) binom(i, k) a_i
$
$
  f_k = sum_(i>=k) (-1)^(i-k) binom(i, k) g_k
$
得到一个卷积形式的式子
$
  f_k / k! = sum_(i>=k) g_i/i! dot (-1)^(i-k)/(i-k)!
$

=== 循环卷积

当要求长度为 2 的幂次的幂级数的循环卷积时，直接 ntt 就行，快速幂也是同理，逆变换回去的就是正确结果，非 2 的幂需要手动把后面的项移回来

```cpp
ntt(f, 0);
FOR(i, sz) f[i] = f[i].pow(T);
ntt(f, 1);
```

#pagebreak()

== C

=== Prüfer

对 $N$ 个点的*带标号无根树*，给定度数序列 $(d_1, ..., d_N)$ 且 $sum d_i = 2 N - 2$ ，满足度数序列的树的个数是：
$
  (N - 2)! * (product_(sum d_i = 2 * N - 2) 1/(d_i - 1)!)
$

=== 拉格朗日反演

设 $phi(u)$ 是形式幂级数，且 $phi(0) != 0$ 令 $T(x)$ 满足 
$
  T(x) = x phi(T(x))
$
则对 $n >= 1$ ： 
$
  [x^N]T(x) = 1/N [u^(N-1)] phi(u)^N
$

更一般地，对任意形式幂级数 $F(u)$ ：
$
  [x^N]F(T(x)) = 1/N [u^(N-1)] F'(u) phi(u)^N
$

#pagebreak()