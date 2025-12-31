#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "FPS Training Log 20251225",
  desc: [形式幂级数相关 训练记录 20251130],
  date: "2025-12-25",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.sol,
    blog-tags.rec,
  ),
  show-outline: true,
)

#set text(size: 8pt)

#let msk = "■";
#let HL(s) = text(size: 9pt)[*#s*]
#let tab = text[#h(8pt)]
#let endl = linebreak()


= FPS Training Log
== P4491 [HAOI2018] 染色

#HL[题意]

一个长度为 $N$ 的序列，每个位置都可以被染成 $M$ 种颜色中的某一种。

考虑 $N$ 个位置中出现次数恰好为 $s$ 的颜色种数，如果恰好出现了 $s$ 次的颜色有 K 种，则会产生 $W_k​$ 的愉悦度。

求所有可能的染色方案，能获得的愉悦度的和对 $P=1004535809$ 取模的结果是多少。

#HL[解答]

令 $i$ 种颜色出现 $S$ 次的方案数为 $A_i$ 答案为 $ sum_i^M w_i A_i $

对于任意一种颜色数分配 $c_i$ ，方案数是 $ N!/(product_i^M (c_i!)) $

令每个颜色的生成函数为 $ g_i(x) = sum_c^infinity x^c/c! = e^x $

所有颜色的总生成函数就是 $ G(x) = product_i^M g_i (x) = product_i^M (sum_c^N x^c/c!) $

$ [x^N]G(x) = sum_(sum c_i = N) 1/(product c_i !) $

需要的就是 $ N! [x^N] G(x) = N! [x^N] g(x)^M $

用另一个变量 $y$ 来标记 出现了 $s$ 次的颜色 $ f(x, y) = sum_(c!=s) x^c/c! + y x^s/s! = e^x + (y-1)x^s/s! $
$ F(x, y) = f(x, y)^M $
$ A_k = N! [x^N] [y^k] F(x, y) $

答案为 $ sum_(k=0)^M w_k A_k = N! [x^N] sum_(k=0)^M w_k [y^k]F(x, y) $

$
  F(x, y) & = (e^x + (y-1)x^s/s!)^M \
          & = sum_(k=0)^M binom(M, k) ((y-1)x^s/s!)^k (e^x)^(M-k) \
          & = sum_(k=0)^M binom(M, k) (y - 1)^k (x^(s k)/(s!)^k e^((M-k)x))
$

令 $ T_k (x) = binom(M, k) x^(s k)/(s!)^k e^((M-k)x) $

变换 $F(x, y)$
$
  sum_(k=0)^M w_k [y^k]F(x, y) & = sum_(k=0)^M w_k [y^k] sum_(i=0)^M (y-1)^i T_i(x) \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^M w_k [y^k] (y-1)^i \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^M w_k [y^k] sum_(j=0)^i binom(i, j) (-1)^(i-j) y^j \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^M w_k binom(i, k) (-1)^(i-k) \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^i w_k binom(i, k) (-1)^(i-k)
$

令
$ d_i = sum_(k=0)^i w_k binom(i, k) (-1)^(i-k) $
故
$ sum_(k=0)^M w_k [y^k]F(x, y) = sum_(k=0)^M d_k T_k (x) $

现在要求 $ N![x^N]sum_(k=0)^M d_k T_k (x) $

$
  [x^N]T_k (x) & = [x^N]binom(M, k) x^(s k)/(s!)^k e^((M-k)x) \
               & = binom(M, k) 1/(s!)^k [x^(N-s k)]e^((M-k)x) \
               & = binom(M, k) 1/(s!)^k [x^(N-s k)]sum_(i=0)^infinity (M-k)^i / i! x^i \
               & = binom(M, k) 1/(s!)^k (M-k)^(N-s k) / (N-s k)!
$

答案就是
$
  N!sum_(k=0)^M d_k binom(M, k) 1/(s!)^k (M-k)^(N-s k) / (N-s k)!
$


现在求 $d_i$

$
  d_i & = sum_(k=0)^i w_k binom(i, k) (-1)^(i-k) \
      & = sum_(k=0)^i w_k i!/(k! (i-k)!) (-1)^(i-k) \
      & = i!sum_(k=0)^i w_k / k! dot (-1)^(i-k)/(i-k)! \
      & = i![x^i](sum_k w_k/k!)(sum_k (-1)^k/k!)
$

显然是个卷积

#pagebreak()

== P4451 [国家集训队] 整数的lqp拆分

#HL[题意]

令 $F_i$ 为斐波那契数列，求 $sum product_(i=0)^m F_a_i$，其中

$m>0$ #endl
$a_1, a_2, ..., a_m > 0$ #endl
$a_1 + a_2 + ... + a_m = n$

#HL[解答]

设斐波那契数列的生成函数 $F(x) = sum_(i=0)^infinity a_i x^i$
有
$
      F(x) & = & a_0 + a_1 x + a_2 x^2 + ... \
    x F(x) & = &       a_0 x + a_1 x^2 + ... \
  x^2 F(x) & = &               a_0 x^2 + ...
$
相减得
$
  (1-x-x^2)F(x) = a_0 + (a_1 - a_0)x = x
$
$
  F(x) = x/(1-x-x^2)
$

所以我们要求的就是
$
  [x^N]sum_(i=0)^infinity F(x) & = [x^N] 1/(1-F(x)) \
                               & = [x^N] (1-x-x^2)/(1-2x-x^2)
$
最终我们要求的是一个有理式的第 $N$ 项系数，可以贴板子了。

注意本题的 $N$ 非常大，由费马小定理，可以将 $N$ 对 $mod - 1$ 取模

#zebraw(
  ```cpp
  using mint = M17;
  void Yorisou() {
    ll N = 0;
    STR(s);
    for (char c : s) {
      c -= '0';
      N = N * 10 + c;
      N %= mint::get_mod() - 1;
    }
    vc<mint> f(3), g(3);
    f[0] = 1, f[1] = -1, f[2] = -1;
    g[0] = 1, g[1] = -2, g[2] = -1;
    print(coef_of_rational_fps(f, g, N));
  }
  ```,
)
#pagebreak()
== P4389 付公主的背包

#HL[题意]

给 $N$ 个物品做完全背包，问恰好装了 $S$ 容量的方案数，范围都是 $10^5$

#HL[解答]

取一件体积 $a$ 物品做完全背包就是乘上一个多项式
$
  f(x) & = 1 + x^a + x^(2a) + ... \
       & = sum_(i=0)^infinity x^(a i) \
       & = 1/(1-x^a)
$
所以答案就是
$
  [x^S]product_(i=0)^(N) 1/(1-x^(a_i))
$
直接 exp
#zebraw(
  ```cpp
  template <typename mint>
  vc<mint> prod_of_inv_one_minus_xn(vc<int> a, int sz) {
    vc<int> c(sz + 1);
    for (int x : a) if (x <= sz) ++c[x];
    if (c[0]) return vc<mint>(sz + 1);
    vc<mint> f(sz + 1);
    FOR(x, 1, sz + 1) FOR(d, 1, sz / x + 1) f[d * x] += mint(c[x]) * inv<mint>(d);
    return fps_exp(f);
  }
  ```,
)

#pagebreak()

== P5110 块速递推

#HL[题意]

给出数列 $a_n = 233a_(n-1) + 666a_(n-2)$ 其中 $a_0 = 0, a_1 = 1$

$5e 7$ 次询问数列第 $n$ 项，$n in [0, 10^9)$

#HL[解答]

有特征多项式
$
  f(t) = t^2 - 233t - 666
$
若存在两个不同根 $alpha, beta$ ，那么有通解：
$
  a_n = A alpha^n + B beta^n
$
求出根后代入前两项，求出 $A, B$ ，得到通项公式，最后使用 $O(1)$ 快速幂求答案

#zebraw(
  ```cpp
  using mint = M17;
  ull SA, SB, SC;
  void init() { IN(SA, SB, SC); }
  ull gen() {
    SA ^= SA << 32, SA ^= SA >> 13, SA ^= SA << 1;
    ull t = SA;
    SA = SB, SB = SC, SC ^= t ^ SA;
    return SC;
  }
  void Yorisou() {
    constexpr mint a = (mint(233) + mod_sqrt(mint(233 * 233) + mint(4 * 666))) * mint(2).inv();
    constexpr mint b = (mint(233) - mod_sqrt(mint(233 * 233) + mint(4 * 666))) * mint(2).inv();
    pow_fast<mint> f(a), g(b);
    constexpr mint A = (a - b).inv();

    INT(Q);
    init();
    ull s = 0;
    FOR(Q) {
      ull x = gen() % (mint::get_mod() - 1);
      s ^= (A * (f(x) - g(x))).val;
    }
    print(s);
  }
  ```,
)

== P5748 集合划分计数

#HL[题意]

多次询问将 $n$ 个元素的集合划分为非空子集的方案数

#HL[解答]

用 bell 数预处理出 $10^5$ 内的答案，就做完了

#zebraw(
  ```cpp
  using mint = M99;
  void Yorisou() {
    vc<mint> f = bell<mint>(1'000'00);
    INT(Q);
    FOR(Q) {
      INT(x);
      print(f[x]);
    }
  }
  ```,
)

#pagebreak()

== P5824 十二重计数法
#HL[题意]

有 $n$ 个球 $m$ 个盒子，给出一系列限制条件，求有多少放球的方案
+ 球之间互不相同，盒子之间互不相同。
+ 球之间互不相同，盒子之间互不相同，每个盒子至多装一个球。
+ 球之间互不相同，盒子之间互不相同，每个盒子至少装一个球。
+ 球之间互不相同，盒子全部相同。
+ 球之间互不相同，盒子全部相同，每个盒子至多装一个球。
+ 球之间互不相同，盒子全部相同，每个盒子至少装一个球。
+ 球全部相同，盒子之间互不相同。
+ 球全部相同，盒子之间互不相同，每个盒子至多装一个球。
+ 球全部相同，盒子之间互不相同，每个盒子至少装一个球。
+ 球全部相同，盒子全部相同。
+ 球全部相同，盒子全部相同，每个盒子至多装一个球。
+ 球全部相同，盒子全部相同，每个盒子至少装一个球。

#HL[解答]

+ 每个球随便乱放都不一样，答案为 $m^n$
+ 选 $n$ 个盒子乱放，由于球各不相同，乘个阶乘 $binom(M, N) * "fact"(N)$
+ 将 $n$ 个球划分成 $m$ 个非空集合，由于盒子不同，乘上阶乘，用第二类斯特林数求解
+ 将 $n$ 个球划分成非空集合，用第二类斯特林数求解
+ 盒子够就 1 否则 0
+ 将 $n$ 个球划分成 $m$ 个非空集合，用第二类斯特林数求解
+ 插板法 $binom(N + M - 1, M - 1)$
+ 选盒子就行 $binom(M, N)$
+ 先往每个盒子里塞一个，然后变成了 $7$ ，插板即可 $binom(N - 1, M - 1)$
+ 实际上是求 $n$ 的不同划分数量，考虑将 $n$ 划分成若干段，每段有自己的长度，朴素的看就是 $a_i$ 个长度 $b_i$ 的段凑出 $n$ 的方案数，限制在于总长度为 $n$ 和段数不超过 $m$ ，直接每种用长度（容量）做 完全背包的话难以描述 $m$ 的限制，考虑转一下，交换长度和个数，这样就是一个完全背包，求
  $
    [x^n]product_(i=1)^m sum_(k=0)^infinity x^(i k)
  $
  也就是
  $
    [x^n]product_(i=1)^m 1/(1-x^i)
  $
  现在就是可以使用科技解决的问题了。
+ 盒子够就 1 否则 0
+ 先往每个盒子塞一个，然后变成了 $10$

#pagebreak()

== P3321 [SDOI2015] 序列统计

#HL[题意]

有一个大小 $S$ 的集合，求从 $S$ 中每次选一个数组成的序列 $a$ ，使得 $product_i^N a_i mod M equiv x$ 的方案数

#HL[解答]

如果是 $sum equiv x$ 的话很简单，就是个朴素的幂级数快速幂（$[x^X](sum_i^M x^(s_i))^N$），乘积可以将原式子取对数，这样变成了指数的 $sum mod M equiv log_g s$ 问题，所以可以求出原根和基于原根的对数表，然后进行 $mod M$ 的循环卷积的快速幂运算来解决

#zebraw(
  ```cpp
  using mint = modint<1004535809>;
  void conv(vc<mint> &f, vc<mint> &g, int p) {
    f = convolution(f, g);
    FOR(i, p, len(f)) f[i - p] += f[i];
    f.resize(p);
  }
  void pow(vc<mint> &f, int k) {
    int sz = len(f);
    vc<mint> s(sz);
    s[0] = 1;
    for (; k; k >>= 1, conv(f, f, sz))
      if (k & 1) conv(s, f, sz);
    f.swap(s);
  }
  void Yorisou() {
    INT(N, M, x, sz);
    VEC(int, s, sz);
    vc<int> t = log_table(M);
    vc<mint> f(M - 1);
    for (int x : s) if (x) f[t[x]] = 1;
    pow(f, N);
    print(f[t[x]]);
  }
  ```,
)
