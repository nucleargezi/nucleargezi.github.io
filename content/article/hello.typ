#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Hello Typst Blog",
  desc: [一篇用来验证 Astro + Typst 模板、代码块、公式和图片的示例文章。],
  date: "2026-03-19",
  tags: ("hello", "typst"),
)

= Hello
这是正文内容。行内公式示例：$a^2 + b^2 = c^2$。

== 2
test

=== 3
test
==== 4
test
===== 5
test

= Test Math

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

$
sum_(i = 1)^n i = (n (n + 1)) / 2
$

你也可以直接插入链接：#link("https://github.com/nucleargezi/acm-icpc/tree/master", [GitHub 仓库]).

#figure(image("/public/images/typst-grid.svg", alt: "yorisou"), caption: "yorisou")


#image("/public/images/typst-grid.svg", width: 70%)

== Code Example

阿巴阿巴 ``` print("Ciallo") ```

```cpp
using P = pair<int, ll>;
bool cp(P a, P b) {
  if (a.fi == -inf<int>) return 1;
  return (i128)a.se * b.fi > (i128)a.fi * b.se;
}
struct X {
  vc<P> a;
  bool fail(P a, P b, P c) {
    b.fi -= a.fi, b.se -= a.se;
    c.fi -= a.fi, c.se -= a.se;
    return b.fi * c.se - b.se * c.fi <= 0;
  }
  void merge(const X &p) {
    for (const P &x : p.a) {
      while (len(a) > 1 and fail(ed(a)[-2], ed(a)[-1], x)) pop(a);
      a.ep(x);
    }
  }
  P sb(P a, P b) {
    a.fi -= b.fi, a.se -= b.se;
    return a;
  }
  P f(P X) {
    int l = 0, r = len(a), a = l - 1, x, b, s = 1, t = 2;
    while (t < r - l + 2) swap(s += t, t);
    x = a + t - s, b = a + t;
    P fx = sb(a[x], X), fy;
    while (a + b != 2 * x) {
      int y = a + b - x;
      if (r < y or (fy = sb(a[y], X), cp(fy, fx))) {
        b = a, a = y;
      } else {
        a = x, x = y, fx = fy;
      }
    }
    return a[x];
  }
};
void Yorisou() {
  INT(N, Q);
  ++N;
  vc<P> a(N);
  FOR(i, 1, N) IN(a[i].se), a[i].se += a[i - 1].se, a[i].fi = i;

  int sz = 1;
  while (sz < N) sz <<= 1;
  vc<X> dat(sz << 1);
  FOR(i, N) dat[i + sz].a.ep(a[i]);
  FOR_R(i, 1, sz) {
    dat[i] = dat[i << 1];
    dat[i].merge(dat[i << 1 | 1]);
  }
  
  FOR(Q) {
    INT(l, r);
    r += l;
    P res{-inf<int>, -inf<ll>}, x = a[l - 1];
    l += sz, r += sz;
    while (l < r) {
      if (l & 1) {
        P g = dat[l].f(x);
        g.fi -= x.fi, g.se -= x.se;
        if (cp(res, g)) res = g;
        ++l;
      }
      if (r & 1) {
        --r;
        P g = dat[r].f(x);
        g.fi -= x.fi, g.se -= x.se;
        if (cp(res, g)) res = g;
      }
      l >>= 1, r >>= 1;
    }
    ll s = floor<ll>(res.se, res.fi);
    if (s < 0) print("stay with parents");
    else print(s);
  }
}
```
