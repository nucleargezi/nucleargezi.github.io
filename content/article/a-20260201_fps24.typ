#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record FPS24",
  desc: [FPS24 个人题解],
  date: "2026-02-01",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.rec,
  ),
  show-outline: true,
)

#set text(size: 8pt)

#let msk = "■";
#let HL(s) = text(size: 9pt)[*#s*]
#let tab = text[#h(8pt)]
#let endl = linebreak()
#let prod = $product$

= FPS 24 Solution

#link("https://atcoder.jp/contests/fps-24/tasks", "Link")

前面的题比较简单或者板, 有些题可以用幂级数的方法分析也可以用别的方法做, U V W X 我不会

== A - お菓子

#HL[题意]

每天可以花费 ${1, 3, 4, 6}$ 元, 求 $D$ 天后恰好花费 $N$ 元的方案数

#HL[解答]

基础题

令状态为花费 $i$ 元的方案数

每天的状态转移就是乘上一个多项式 $f = x + 3x + 4x + 6x$

答案是 $[x^N]f^D$

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(D, N);
  fps f(max(N + 1, 7));
  f[1] = f[3] = f[4] = f[6] = 1;
  print(fps_pow(f, D)[N]);
}
```

#pagebreak()


== B - 整数の組

#HL[题意]

求满足以下条件的非负四元组 $(a,b,c,d)$ 的数量
- $a + b + c + d = N$
- $a in {0, 1}$
- $b in {0, 1, 2}$
- $c$ 是偶数
- $d$ 是 $3$ 的倍数

#HL[解答]

基础题

$
     f_a & = 1 + x \
     f_b & = 1 + x + x^2 \
     f_c & = sum_i (x^2)^i = 1 / (1-x^2) \
     f_c & = sum_i (x^3)^i = 1 / (1-x^3) \
  prod f & = 1 / (1-x)^2
$

答案为第 $N$ 项系数, 这个式子的系数可以很简单地求出来

$
  g := 1 / (1-x) = sum_i x^i \
  prod f = g * g
$

从 dp 的角度考虑, 乘 $g$ 就是每个位置向后面的每个位置转移了一次, 所以 ${1, 1, 1, ...}$ 转移一次就是 ${1, 2, 3, ...}$ , 故答案为 $N + 1$

```cpp
using mint = M99;
void Yorisou() {
  mint N;
  IN(N);
  print(N + 1);
}
```

#pagebreak()

== C - 数列

#HL[题意]

求长度为 $N$, 每个数值域 $[0, M]$, 且总和为 $S$ 的整数序列的个数

#HL[解答]

基础题

每个位置的转移是 $f = sum_(i=0)^M x^i$

答案为 $[x^S]f^N$

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N, M, S);
  fps f(S + 1);
  FOR(i, min(M, S) + 1) f[i] = 1;
  print(fps_pow(f, N)[S]);
}
```

#pagebreak()

== D - 数列 2

#HL[题意]

求长度为 $N$ , 每个数值域 $[0, M]$ , 排序后相邻两项奇偶性不同的整数序列个数

#HL[解答]

基础题

可以求排序后的序列个数, 结果乘上 $N!$

排序后的序列的差分是个总和不超过 $M$ 的奇数序列, 计算并统计它的前 $M + 1$ 项和即可, 方法和 $B$ 类似

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N, M);
  fps f(M + 1), p(M + 1);
  fill(all(p), 1);
  FOR(i, 1, M + 1) if (i & 1) f[i] = 1;
  f = fps_pow(f, N - 1);
  f = p * f;
  sh(f, M + 1);
  print(SUM<mint>(f) * fac(N));
}
```

#pagebreak()

== E - 数列 3

#HL[题意]

求长度为 $N$ 每个数值域 $[1, M]$ 且每个值 $i$ 出现次数不超过 $i$ 次的序列个数

#HL[解答]

基础题

$N, M$ 都很小, 直接 dp

```cpp
using mint = M99;
void Yorisou() {
  INT(N, M);
  vc<mint> dp(N + 1), ndp(dp);
  dp[0] = 1;
  FOR(i, 1, M + 1) {
    fill(all(ndp), 0);
    FOR(t, i + 1) FOR(i, N - t + 1) ndp[i + t] += dp[i] * CC(N - i, t);
    swap(dp, ndp);
  }
  print(dp[N]);
}
```

#pagebreak()

== F - 色紙

#HL[题意]

一个长度为 $N$ 的序列, 对它染色 红蓝黄三种颜色
- 蓝色数量要是偶数
- 黄色数量要是奇数

#HL[解答]

直接 dp , 很显然可以这样

```cpp
FOR(i, 2) FOR(k, 2) {
  ndp[i][k] += dp[i][k];
  ndp[i][k ^ 1] += dp[i][k];
  ndp[i ^ 1][k] += dp[i][k];
}
ans = dp[1][0];
```

把它写成矩阵形式就可以矩阵快速幂了
```cpp
FOR(i, 2) FOR(k, 2) {
  cerr << format("f[{}][{}] += 1;\n", i * 2 + k, i * 2 + k);
  cerr << format("f[{}][{}] += 1;\n", i * 2 + (k ^ 1), i * 2 + k);
  cerr << format("f[{}][{}] += 1;\n", (i ^ 1) * 2 + k, i * 2 + k);
  ndp[i][k] += dp[i][k];
  ndp[i][k ^ 1] += dp[i][k];
  ndp[i ^ 1][k] += dp[i][k];
}
```
```cpp
using mint = M99;
using M = mat<mint>;
void Yorisou() {
  LL(N);
  M f(4, 0, 0);
  f[0][0] += 1;
  f[1][0] += 1;
  f[2][0] += 1;
  f[1][1] += 1;
  f[0][1] += 1;
  f[3][1] += 1;
  f[2][2] += 1;
  f[3][2] += 1;
  f[0][2] += 1;
  f[3][3] += 1;
  f[2][3] += 1;
  f[1][3] += 1;
  f = f.pow(N);
  print(f[2][0]);
}
```

显然它还是个线性递推, 所以也可以插出来:
```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  LL(N);
  array<array<mint, 2>, 2> dp{}, ndp{};
  dp[0][0] = 1;
  fps f;
  FOR(i, 4) {
    f.ep(dp[1][0]);
    FOR(i, 2) FOR(k, 2) ndp[i][k] = 0;
    FOR(i, 2) FOR(k, 2) {
      ndp[i][k] += dp[i][k];
      ndp[i][k ^ 1] += dp[i][k];
      ndp[i ^ 1][k] += dp[i][k];
    }
    dp.swap(ndp);
  }
  print(line_inte(f, N));
}
```

#pagebreak()

== G - 硬貨

#HL[题意]

问用 $[m, m + L - 1) , m in [1, M - L + 1]$ 面值硬币凑出 $N$ 的方案数

#HL[解答]

这是个模板题, 完全背包的计数是可撤回的

```cpp
using mint = M99;
void Yorisou() {
  INT(N, M, L);
  vc<mint> f(N + 1);
  f[0] = 1;
  Z ad = [&](int t) { FOR(i, t, N + 1) f[i] += f[i - t]; };
  Z rm = [&](int t) { FOR_R(i, t, N + 1) f[i] -= f[i - t]; };
  FOR(i, 1, M + 1) {
    ad(i);
    if (i >= L) print(f[N]), rm(i - L + 1);
  }
}
```

#pagebreak()

== H - ジャンプ

#HL[题意]

格路计数, 每次 $x$ 轴移动 $[0, 1]$ 格子, $y$ 轴移动 $[0, +infinity]$ 格子, 不能不动, 问到 $N, M$ 的方案数

#HL[解答]

首先它的路径总共肯定是 $binom(N + M, N)$ 条, 但每条路径对应的方案数可能不止一种, 对 $arrow.t$ 进行拆分, 它会有一个可以为空的前缀并入前面的 $arrow$ , 后面的部分被划分成任意个非空集合, 这样一段的方案数就是 $sum_(i=0)^(|S| - 1) 2^i = 2^(|S|)$ , 总的就是每一段的乘积 $2^M$ , 但如果开头不是 $arrow$ , 第一段 $arrow.t$ 的前缀是无法并入的, 所以这段方案数只有 $2^(|S - 1|)$ , 两类统计一下

```cpp
using mint = M99;
void Yorisou() {
  INT(N, M);
  print(CC(N + M - 1, N - 1) * mint(2).pow(M) +
        CC(N + M - 1, N) * mint(2).pow(M - 1));
}
```

#pagebreak()

== I - スコア

#HL[题意]

给 $N$ 个不同整数, 求所有选 $K$ 个数方案的乘积的和

#HL[解答]

基础题

还是从 dp 的角度考虑问题, 用 $i$ 次项系数表示选 $i$ 个数的乘积和, 任意一个数 $c$ 选与不选就是乘上 $f = 1 + c dot x$ , 可以用分治卷积计算

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N, K);
  VEC(mint, a, N);
  vc<fps> f(N);
  FOR(i, N) f[i] = {1, a[i]};
  print(conv_all(f)[K]);
}
```

#pagebreak()

== J - スゴロク

#HL[题意]

有个 $N+1$ 个格子的棋盘, 要从 $0$ 走到 $N$ , 有个 $M$ 面骰子, 等概率掷出 $a_i$ , 掷出多少走几步, 有 $L$ 个陷阱, 到了就死了, 问成功到达 $N$ 的概率, 超过也算到

#HL[解答]

这道题告诉我如果要写题解得趁早写, 过一个月忘记之前写的啥了

转移就是$f[i] = p sum_k f[i - a_k]$, 然后把陷阱处的系数清零, 直接在线卷积卷过去, 然后对每个点到终点的概率求和

```cpp
using mint = M99;
void Yorisou() {
  INT(N, M, L);
  vc<int> a(N + 1);
  FOR(M) {
    INT(x);
    a[x] = 1;
  }
  vc<u8> vis(N + 1);
  FOR(L) {
    INT(x);
    vis[x] = 1;
  }
  online_conv<mint> g;
  vc<mint> f(N + 1);
  mint im = mint(M).inv();
  f[0] = 1;
  FOR(i, N) {
    f[i + 1] = g(f[i], a[i + 1]) * im;
    if (vis[i + 1]) f[i + 1] = 0;
  }
  mint s = 0;
  FOR_R(i, N) a[i] += a[i + 1];
  FOR(i, N) s += f[i] * a[N - i] * im;
  print(s);
}
```

#pagebreak()

== K - 順列

#HL[题意]

问满足 $max(a[0, i]) != i , i in [0, N - 1)$ 的排列数量

#HL[解答]

令 $g$ 为无法被再拆分的合法排列类的生成函数, 任意一个排列的生成函数就是

$
  f & = sum_(i=0) g^i = 1 / (1-g) \
  g & = 1 - 1 / f
$
求逆即可

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N);
  fps f(N + 1);
  FOR(i, N + 1) f[i] = fac(i);
  print(-fps_inv(f)[N]);
}
```

#pagebreak()

== L - 順列 2

#HL[题意]

求满足 $p_p_i != i$ 的排列数量

#HL[解答]

排列中没有长度为 $1, 2$ 的置换环, 可以将合法置换环的生成函数 $f$ 写出来, 答案的生成函数是合法置换环森林, 也就是 exp(f)

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N);
  fps f(N + 1);
  FOR(i, 3, N + 1) f[i] = fac(i - 1) * ifac(i);
  f = fps_exp(f);
  print(f[N] * fac(N));
}
```

#pagebreak()

== M - 連結グラフ

#HL[题意]

带标号无向连通图计数

#HL[解答]

带标号无向图的数量是 $2^binom(N, 2)$

带标号无向连通图的 egf 是前者取对数

```cpp
template <typename mint>
vc<mint> count_label_undir_con(int N) {
  vc<mint> f = count_label_undir<mint>(N);
  FOR(i, N + 1) f[i] *= ifac(i);
  f = fps_log(f);
  FOR(i, N + 1) f[i] *= fac(i);
  return f;
}
```

#pagebreak()

== N - 硬貨 2

#HL[题意]

有 $a_i$ 枚价值 $i$ 的硬币, 求凑出 $N$ 元的方案数

#HL[解答]

答案是
$
  prod_(i=1) sum_(k=0)^(a_i) (x^i)^k = prod_(i=1) (1 - x^(i*(a_i + 1))) / (1 - x^i)
$

上下都是 prod of $1-x^n$ 形式的东西 , 直接分别求一下卷起来即可

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N);
  VEC(int, a, N);
  vc<int> coef(N);
  FOR(i, N) coef[i] = min<ll>(N + 1, ll(i + 1) * (a[i] + 1));
  fps f = prod_of_one_minus_xn<mint>(coef, N);
  FOR(i, N) coef[i] = i + 1;
  fps g = prod_of_inv_one_minus_xn<mint>(coef, N);
  mint s = 0;
  FOR(i, N + 1) s += f[i] * g[N - i];
  print(s);
}
```

#pagebreak()

== O - 根付き木

#HL[题意]

求非叶子节点儿子个数为质数的树的数量

#HL[解答]

Prüfer 序列练习题

对 $N$ 个点的带标号无根树，给定度数序列 $(d_1, ..., d_N)$ 且 $sum d_i = 2 N - 2$ ，满足度数序列的树的个数是：
$
  (N - 2)! * (prod_(sum d_i = 2 * N - 2) 1/(d_i - 1)!)
$

根的次数是质数, 其他点的次数是 $1$ 或者质数 $+1$

直接对着式子求

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N);
  fps f(2 * N - 1), g(f);
  vc<int> pt = primtable(N);
  for (int x : pt) f[x] = ifac(x - 1);
  g[1] = 1;
  for (int x : pt) g[x + 1] = ifac(x);
  print((f * fps_pow(g, N - 1))[2 * N - 2] * fac(N - 2));
}
```

#pagebreak()

== P - ボール

#HL[题意]

给定 $N, M, K$ , 对于 $m in {1, 2, ..., M}$ , 求 $N$ 个带标号球放 $m + 1$ 个带标号盒子的方案数, 盒子 $0$ 只能放 $K$ 个球

#HL[解答]

对于每个 $m$ 实际上就是选 $[0, K]$ 个球扔 盒子 0 中, 剩下的随便给 $m$ 个集合, 也就是 $sum_(i=0)^K binom(N, i) m^(N-i)$ , 这是一个关于 $m$ 的多项式, 答案直接多点求值

```cpp
using mint = M99;
using fps = vc<mint>;
void Yorisou() {
  INT(N, M, K);
  fps f(N + 1);
  FOR(i, K + 1) f[N - i] = CC(N, i);
  fps x(M);
  iota(all(x), 1);
  for (mint s : multi_eval(f, x)) print(s);
}
```

#pagebreak()

== Q - サイコロ

#HL[题意]

两个骰子
- 骰子 1 $N$ 面等概率掷出 $A_i$
- 骰子 2 $M$ 面等概率掷出 $B_i$
对于 $p in [1, K]$ 求 投掷两个骰子各一次的点数之和的 $p$ 次幂的期望

- $N, M, K <= 10^5$


#HL[解答]

总的来说要求
$
  1/(N M) sum_(i=0)^N sum_(k=0)^M (A_i + B_k)^p tab p in [1, K]
$
二项式定理
$
  sum_(i=0)^N sum_(k=0)^M (A_i + B_k)^p & = sum_(i=0)^N sum_(k=0)^M sum_(k=0)^p binom(p, j) A_i^j B_k^(p-j) \
                                        & = sum_j^p binom(p, j) sum_(i=0)^N sum_(k=0)^M A_i^j B_k^(p-j) \
                                        & = sum_j^p binom(p, j) sum_(i=0)^N A_i^j sum_(k=0)^M B_k^(p-j)
$
令
$
  C_i = sum_(k=0)^N A_k^i tab , D_i = sum_(k=0)^M B_k^i
$
则上式为
$
  sum_(j=0)^p binom(p, j) C_j D_(p-j) & = sum_(j=0)^p p!/(j! (p-j)!) C_j D_(p-j) \
                                      & = p! sum_(j=0)^p C_j / j! * D_(p-j) / (p-j)!
$
凑出了个卷积

$C$ 和 $D$ 是两个 sum of pow , 求完乘上系数卷一下, 最后乘上 $p! * 1 / (N M)$ 就是答案

#zebraw(
  ```cpp
  using mint = M99;
  void Yorisou() {
    INT(N, M, K);
    VEC(mint, a, N);
    VEC(mint, b, M);
    vc<mint> c = sum_of_pow(a, K), d = sum_of_pow(b, K);
    FOR(i, K + 1) c[i] *= ifac(i);
    FOR(i, K + 1) d[i] *= ifac(i);
    c = c * d;
    mint in = mint(1) / N / M;
    FOR(i, 1, K + 1) print(c[i] * fac(i) * in);
  }
  ```,
)

#pagebreak()

== R - ランダムウォーク

#HL[题意]

在一个数轴 $[0, 2^N)$ 的 0 点开始随机游走 $T$ 轮, 问最终停在 $X$ 点的概率

- $N <= 20, T <= 10^18$

#HL[解答]

如果它是一个环, 就可以很容易地表示出来:  $[x^X](1/2 x^1 + 1/2 x^(-1))^T mod(x^2^(N+1) - 1)$ , 但数轴不是环, 它的的端点需要特殊处理

将数轴补到 $2^(N+1)$ : $0, 1, 2, ..., 2^N - 2, 2^N - 1, 2^N - 2', ..., 2', 1'$ 将其看作一个环, 相当于设置了一个循环的镜像来让端点的状态转移也变得平凡, 将环上游走的镜像点贡献合并就和原数轴上随机游走一样, 这样要求的就变成了
$
  [x^X](1/2 x^1 + 1/2 x^(2^(N+1) - 1))^T mod(x^2^(N+1) - 1)
$
这样的一个循环卷积, 由于环长是 2 的幂, 可以直接 ntt 处理, 跑快速幂应该会 TLE , 注意端点无镜像点

#zebraw(
  ```cpp
  using mint = M99;
  void Yorisou() {
    LL(N, T, x);
    --x;
    int sz = 1 << (N + 1);
    vc<mint> f(sz);
    f[1] = 1;
    f[sz - 1] = 1;
    ntt(f, 0);
    FOR(i, sz) f[i] = f[i].pow(T);
    ntt(f, 1);
    mint ans;
    FOR(i, sz) if (i == x or i == (sz - x)) ans += f[i];
    print(ans * mint(2).inv().pow(T));
  }
  ```,
)

#pagebreak()

== S - ゲーム

#HL[题意]

Alice 和 Bob 在一颗 $N$ 个节点的树上博弈, Alice 将棋子放在 $1, 2, ..., K$ 中的一个节点, 然后 Bob 先手开始轮流访问一个相邻的未到达的顶点, 无法移动的输
- subtask1 $K = 1$
- subtask2 $K = N$

#HL[解答]

- subtask1

对于 $K = 1$ 设 $A(x)$ 为先手必败的根树种 , $B(x)$ 为先手必胜的根树种 , 则 $A$ 是根接上 先手必胜的有根树的集合, $B$ 是 有根树种 减去 A
$
  A = x exp(B) tab, tab B = "EGF"_"rooted tree" - A
$
通过在线 $exp(B)$ 可以求出答案, 由于根固定需要 $\/ i$

#zebraw(
  ```cpp
  vc<mint> A(N + 1), B = count_label_tree<mint>(N);
  FOR(i, 1, N + 1) B[i] *= ifac(i) * i;
  online_exp<mint> expB;
  FOR(i, 1, N + 1) {
    A[i] = expB(B[i - 1]);
    B[i] = B[i] - A[i];
  }
  FOR(i, 2, N + 1) print(A[i] * fac(i) * inv<mint>(i));
  ```,
)

也可以用牛顿迭代来做, 比在线 exp 慢一些

$A, B$ 的定义不变, $B$ 是 根接上存在先手必败的根树的集合
$
  A = x exp(B) tab \
  B = x(exp(A + B) - exp(B)) \
  B = x(exp(x exp(B) + B) - exp(B))
$
$
  G(B) := B - x(exp(x exp(B) + B) - exp(B)) = 0 \
  G'(B) = 1 - x(exp(x exp(B) + B)(x exp(B) + 1) - exp(B))
$
牛顿迭代即可
#zebraw(
  ```cpp
  const fps x{0, 1}, one{1};
  pair<fps, fps> ke(fps B, int N) {
    sh(B, N);
    fps E = fps_exp(B);
    fps H = E * x + B;
    sh(H, N);
    fps F = fps_exp(H);
    fps g = (B - x * (F - E));
    sh(g, N);
    fps dg = one - x * (F * (x * E + one) - E);
    sh(dg, N);
    return {g, dg};
  }

  fps B = newton(ke, mint(0), N + 1);
  fps A = x * fps_exp(B);
  FOR(i, 2, N + 1) print(A[i] * fac(i) * inv<mint>(i));
  ```,
)

#pagebreak()

- subtask2
先手获胜要求整棵树是一个完美匹配, 先手从起点开始可以一直走匹配的边, 非完美匹配可以取一个最大匹配, 使起点设置在最大匹配外, 后手就能一直走匹配的边, 令 $f$ 为完美匹配根树种, $g$ 为 根接的子树都是完美匹配根树  的种
$
  f = x g exp(f) tab, tab g = x exp(f)
$
代入得
$
  f & = x^2 exp(f)^2 \
    & = x^2 exp(2f)
$
拉格朗日反演, 令 $u = x^2 , y = f$
$
  y = u phi.alt(y) tab , tab phi.alt(y) = e^(2y) \
  [u^N]y = 1 / N [t^(N - 1)]e^(2 N t) \
  e^(2 N t) = sum_(k>=0) (2N)^k / k! t^k => [t^(N-1)]e^(2 N t) = (2N)^(N-1) / (N-1)! \
  [u^N]y = 1 / N * (2N)^(N-1) / (N-1)! = (2N)^(N-1) / N! \
  [x^(2N)]y = (2N)^(N-1) / N!
$
这样就解出了偶数时的答案, 由于是无根树 $\/ i$, 奇数时没有完美匹配

#zebraw(
  ```cpp
  vc<mint> f = count_label_tree<mint>(N);
  FOR(i, 2, N + 1) {
    if (i & 1) print(f[i]);
    else print(f[i] - mint(i).pow(i / 2 - 1) * ifac(i / 2) * inv<mint>(i) * fac(i));
  }
  ```,
)

#pagebreak()

== T - カラフル

#HL[题意]

有 $N$ 种颜色, 每种颜色有 $a_i$ 个不同的位置 , 从一个颜色为 0 的位置开始 T 轮跳跃, 每次跳到一个不同颜色的位置, 最后回到起点, 求方案数

#HL[解答]

对路径进行拆分成若干个块, 每个块都是以 0 为起始颜色, 接上一段其他颜色, 由于必须回到起点, 终点那次跳跃就不管了

对每个块进行分析, 记块长为 $L$ , $c_i$ 为这个块的颜色序列, 则它的方案数是
$
  a_0 product_(i=1)^(L - 1) a_c_i
$
对单个颜色进行容斥, 其权值为
$
  sum_(i>=1) (-1)^(i+1) a_i x^i = 1 - 1 / (1 + a_i x) = (a_i x) / (1 + a_i x)
$
总的就是一个有理式
$
  S = sum_(i=2)^N (a_i x) / (1 + a_i x) = A / B
$
所以对于这段其他颜色, 生成函数为
$
  F = 1 / (1 - S) - 1 = A / (B - A)
$
非起点所在块, 第一个位置是任选颜色为 0 的位置, 生成函数为:
$
  a_0 x F
$
所以答案是
$
  [x^T] F * 1 / (1 - a_0 x F) = A / (B - A - a_0 x A)
$

#zebraw(
  ```cpp
  using mint = M99;
  using fps = vc<mint>;
  void Yorisou() {
    LL(N, T);
    VEC(mint, a, N);
    vc<pair<fps, fps>> fr;
    FOR(i, 1, N) {
      fr.ep(fps{0, mint(a[i])}, fps{1, mint(a[i])});
    }
    Z [A, B] = sum_of_rationals(fr);
    print(coef_of_rational_fps(A, B - A - A * fps{0, mint(a[0])}, T - 1));
  }
  ```,
)
