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

= Group Theory

== Group 群

一个 Group 就是满足以下条件的二元组 $(G, *)$ , $G$ 是集合, $*$ 是集合上的二元运算
- 封闭性: $forall a, b in G, a * b in G$
- 结合率: $forall a, b, c in G, (a * b) * c = a * (b * c)$
- 单位元: $exists e in G, forall a in G , a * e = e * a = a$
- 元素存在逆元 $forall a in G, a * a^(-1) = a^(-1) * a = e$

算法竞赛中常用树状数组维护的那类信息就是 Group , 本文并不会讨论信息维护之类的内容, 更多是和计数相关

== Cyclic Group 循环群

定义: 群 $G$ 中若存在某个元素 $g in G$ , 使得
$
  G = {g^k | k in ZZ}
$

则 $G$ 是循环群, $g$ 叫生成元

循环群的结构只有两种
- 无限循环群: $ZZ$ (整数加法群)
- 有限循环群: $ZZ_N$ (模 $N$ 加法群)
所有阶为 $N$ 的循环群都同构于 $ZZ_N$

== Group Action 群作用
一般在题目中, 群总是作用于某个集合上, 比如所有排列, 所有图案, 所有多重集序列

群 $G$ 作用在集合 $X$ 上, 是一个映射:
$
  G times X -> X , tab (g, x) mapsto g * x
$
满足
- $e * x = x$
- $(g_1 g_2) dot x = g_1 (g_2 dot x)$

== Orbit 轨道
给定 $x in X$ , 它的轨道是
$
  "Orb"(x) = {g dot x | g in G}
$
就是群里的所有作用都对 $x$ 做一遍产生的集合

== Stabilizer 稳定子

给定 $x in X$ , 稳定子是 不会改变 $x$ 的群元素的集合, 它一定是 $G$ 的一个子群
$
  "Stab"(x) = {g in G | g * x = x}
$

== Orbit-Stabilizer 轨道-稳定子定理

若 $G$ 有限, 则
$
  |"Orb"(x)| = |G| / (|"Stab"(x)|)
$

== Burnside 引理

若 $G$ 是有限群, 作用在有限集合 $X$ 上, 则轨道个数为 每个元素的固定点集合大小 取平均值
$
  hash(X \/ G) = 1 / (|G|) sum_(g in G) |"Fix"(g)| \ 
  "Fix"(g) = {x in X | g * x = x}
$

== 例题

=== #link("https://yukicoder.me/problems/no/125", "Yuki 125")

题意

有 $K$ 种不同颜色的花瓣, 分别为 $c_i$ 个, 共 $N <= 10^6$ 个, 问能组成的大小为 $N$ 的花环的数量, 旋转后相同的算同一种

解答

在这题中, 旋转操作本质上就是一个循环群 $C_N$ , $X$ 就是满足颜色数量为 $c$ 的颜色序列, 答案是轨道总数, 利用 Burnside 引理求解, $"Fix"(g)$ 就是旋转 $g$ 次后不变的序列数量

旋转 $i$ 次的操作会将序列分成 $d = gcd(i, N)$ 个环, 每个环大小 $L = N \/ d$ , 要求每种颜色都能被 $L$ 整除, 总方案数为 $N! \/ prod((c_i / L)!)$

由于 $gcd$ 数量并不多, 记忆化一下即可

```cpp
using mint = M17;
void Yorisou() {
  INT(K);
  VEC(int, a, K);
  int N = SUM(a);

  vc<mint> c(N + 1);
  vc<u8> vis(N + 1);
  Z f = [&](int d) -> mint {
    if (vis[d]) return c[d];
    int L = N / d;
    vis[d] = 1;
    for (int x : a) if (x % L != 0) return 0;
    mint s = fac(d);
    for (int x : a) s *= ifac(x / L);
    return c[d] = s;
  };

  mint s = 0;
  FOR(i, N - 1) s += f(gcd(i, N));
  print(s / N);
}
```

to be continue