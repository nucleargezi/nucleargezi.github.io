#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Training Log 20251130",
  desc: [做题记录 20251130],
  date: "2025-11-30",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.sol,
    blog-tags.rec
  ),
  show-outline: false,
)

#set text(size: 8pt)

= 随机写紫题的记录
== 2025-11-30
=== P4767
- link: #link("https://www.luogu.com.cn/problem/P4767");

- 题意：数轴上给定 $N$ 个点，选定 $P$ 个点使得 $N$ 个点到最近选定点距离和最小

首先对于任意一个区间，一定是选定中点最优，可以预处理出每个区间选一个点的 cost ，记为 c[l][r] .

然后有个很显然的转移，令 ndp[i] 为 选定了 x 个点时 到第 i 个点的最小距离和，dp[i] 为 选了 x - 1 个点的，$ "ndp[i]" = min{"dp[k]" + c[k + 1][i], k in [0, i)} $

通过调整可以发现，每轮对于每一个 $i$ 其最优转移点 $k'$ 是单调递增的，使用分治来优化 dp 过程
#zebraw(
```cpp
void Yorisou() {
  INT(N, P);
  VEC(int, a, N);
  sort(a);
  a.insert(a.begin(), 0);
  retsu c(N + 1, N + 1);
  FOR_R(i, 1, N + 1) FOR(k, i, N + 1) 
    c[i][k] = c[i + 1][k - 1] + a[k] - a[i];
  vc<int> dp(N + 1, inf<int>), ndp(dp);
  dp[0] = 0;
  FOR(i, 1, N + 1) dp[i] = c[1][i];
  Z f = [&](Z &f, int l, int r, int ql, int qr) -> void {
    if (l > r) return;
    int m = (l + r) >> 1, id = -1, nr = min(qr, m - 1);
    int e = inf<int>;
    FOR(k, ql, nr + 1) if (chmin(e, dp[k] + c[k + 1][m])) id = k;
    ndp[m] = e;
    if (l < m) f(f, l, m - 1, ql, id);
    if (m < r) f(f, m + 1, r, id, qr);
  };
  FOR(i, 2, P + 1) {
    ndp[0] = 0;
    f(f, i, N, i - 1, N - 1);
    dp.swap(ndp);
  }
  print(dp[N]);
}
```
)
#pagebreak()
=== P1552
- link: #link("https://www.luogu.com.cn/problem/P1552");

- 题意：给一棵树，每个节点 $v$ 有个值 $c_v$ 和 $l_v$ ，令 $S_v$ 为以 v 为根之子树中 c 值之和不超过 K 最大节点数量，求$max_(v in V) l_v S_v.$

直接每个点开个堆启发式合并

#zebraw(
```cpp
void Yorisou() {
  INT(N, V);
  vc<vc<int>> g(N);
  vc<int> c(N), w(N);
  int t = -1;
  FOR(i, N) {
    INT(fa);
    --fa;
    IN(c[i], w[i]);
    if (fa != -1) g[fa].ep(i); 
    else t = i;
  }
  ll ans = 0;
  vc<max_heap<int>> q(N);
  vc<ll> s(N);
  Z f = [&](Z &f, int n) -> void {
    q[n].eb(c[n]), s[n] = c[n];
    for (int t : g[n]) {
      f(f, t);
      s[n] += s[t];
      if (len(q[n]) < len(q[t])) q[n].swap(q[t]);
      while (not q[t].empty()) q[n].eb(pop(q[t]));
    }
    while (s[n] > V) s[n] -= pop(q[n]);
    chmax(ans, w[n] * len(q[n]));
  };
  f(f, t);
  print(ans);
}
```
)
=== P4051
- link: #link("https://www.luogu.com.cn/problem/P4051");

- 题意 没什么好说的

SA 板子

#zebraw(
```cpp
void Yorisou() {
  STR(s);
  int N = len(s);
  s += s;
  pop(s);
  SA sa(s);
  string r;
  FOR(i, N + N - 1) if (sa.sa[i] < N) r += s[sa.sa[i] + N - 1];
  print(r);
}
```
)
#pagebreak()
=== P2473
- link: #link("https://www.luogu.com.cn/problem/P2473");
- 题意：共有 $K$ 轮，有 $n$ 种物品，每一轮出现每一种物品的概率是 $1/n$ ，物品可选可不选，对于选每一种物品，必须要在前面的轮先选给定的部分物品，每一种物品的价格可正可负。求 K 轮后按最优方案选择的期望价格。

倒着 dp ，每轮的每个状态表示当前轮选了 mask 的物品到最终的期望，在可拓展的状态中选最优期望的决策求和 /n

#zebraw(
```cpp
using RE = double;
void Yorisou() {
  INT(K, N);
  vector<PII> a(N);
  FOR(i, N) {
    INT(x);
    a[i].fi = x;
    while (IN(x) and x) --x, a[i].se |= 1 << x;
  }
  int sz = 1 << N;
  vc<RE> dp(sz), ndp(sz);
  FOR(K) {
    FOR(s, sz) {
      ndp[s] = 0;
      FOR(i, N) {
        RE mx = dp[s];
        if (a[i].se == (a[i].se & s)) chmax(mx, a[i].fi + dp[1 << i | s]);
        ndp[s] += mx;
      }
      ndp[s] /= N;
    }
    dp.swap(ndp);
  }
  setp(6);
  print(dp[0]);
}
```
)
#pagebreak()
=== P2596
- link: #link("https://www.luogu.com.cn/problem/P2596");
- 题意：有个序列，支持以下操作：将某个元素放到最前面/最后面、往前/后挪几位，求某个元素的 rk ，求 rk 为 k 的元素

直接平衡树应该就可以，我写了个lct，在前后加了链头链尾，移动用 link / cut ，求 rk 就是 dist(top, s)，求 rk 对应元素就是 jump(top, bot, rk)

#zebraw(
```cpp
void Yorisou() {
  INT(N, Q);
  VEC(int, a, N);
  FOR(i, N) --a[i];
  LCT_base lct(N + 2);
  FOR(i, N - 1) lct.link(a[i], a[i + 1]);
  int top = N, bot = N + 1;
  lct.link(top, a[0]), lct.link(a[N - 1], bot);
  Z cut = [&](int i)  {
    int x = lct.jump(i, top, 1), y = lct.jump(i, bot, 1);
    lct.cut(x, i), lct.cut(i, y);
    lct.link(x, y);
  };
  Z link = [&](int a, int b, int c) {
    lct.cut(a, c);
    lct.link(a, b), lct.link(b, c);
  };
  FOR(Q) {
    STR(op);
    if (op[0] == 'T') {
      INT(s);
      --s;
      cut(s);
      int p = lct.jump(top, bot, 1);
      link(top, s, p);
    } else if (op[0] == 'B') {
      INT(s);
      --s;
      cut(s);
      int p = lct.jump(bot, top, 1);
      link(p, s, bot);
    } else if (op[0] == 'I') {
      INT(s, x);
      --s;
      if (x > 0) {
        int u = lct.jump(s, bot, x), d = lct.jump(u, bot, 1);
        cut(s);
        link(u, s, d);
      }
      if (x < 0) {
        int d = lct.jump(s, top, -x), u = lct.jump(d, top, 1);
        cut(s);
        link(u, s, d);
      }
    } else if (op[0] == 'A') {
      INT(s);
      --s;
      print(lct.dist(top, s) - 1);
    } else if (op[0] == 'Q') {
      INT(s);
      print(lct.jump(top, bot, s) + 1);
    }
  }
}
```
)
#pagebreak()
=== P3527
- link: #link("https://www.luogu.com.cn/problem/P3527");
- 题意：给出一个环形序列，被分为 m 段。有 n 个国家，序列的第 i 段属于国家 oi​。接下来有 k 次事件，每次给环形序列上的一个区间加上一个正整数。每个国家有一个期望 pi​，求出每个国家在序列上所有位置的值的和到达 pi​ 的最早时间（或报告无法达到）。

整体二分模板，大概就是，二分的是时间，每次 check 是 check 一个时间点，而操作也是时间上的一个序列，所以可以做到扫描一遍所有操作并对每个对象 check 一次，非常简单的技巧。

#zebraw(
```cpp
using MX = monoid_add<ll>;
using BIT = dual_fenw<MX>;
void Yorisou() {
  INT(N, M);
  VEC(int, a, M);
  vc<vc<int>> v(N);
  FOR(i, M) v[--a[i]].ep(i);
  VEC(int, nd, N);
  INT(OP);
  VEC(T3<int>, q, OP);
  
  vc<vc<int>> qs(OP + 1);
  vc<PII> res(N, {OP, -1});
  BIT seg(M);
  while (1) {
    bool f = 0;
    FOR(i, OP) qs[i].clear();
    FOR(i, N) {
      Z [l, r] = res[i];
      if (abs(r - l) > 1) f = 1, qs[(l + r) >> 1].ep(i);
    }
    if (not f) break;
    seg.build(M);
    FOR(i, OP) {
      Z [l, r, w] = q[i];
      if (l <= r) seg.apply(l - 1, r, w);
      else seg.apply(0, r, w), seg.apply(l - 1, M, w);
      for (int id : qs[i]) {
        ll s = nd[id];
        for (int x : v[id]) if ((s -= seg.get(x)) <= 0) break;
        if (s <= 0) res[id].fi = i;
        else res[id].se = i;
      }
    }
  }
  for (Z [l, r] : res) {
    if (l == OP) NIE();
    else print(l + 1);
  }
}
```
)
#pagebreak()
=== P4196
- link: #link("https://www.luogu.com.cn/problem/P4196")
- 题意：求半平面交

乱写了个复杂度爆炸的，每次拿一条边去切当前的凸包

#zebraw(
```cpp
using RE = long double;
using P = point<RE>;
void Yorisou() {
  INT(N);
  vc<convex_polygon<RE>> a;
  FOR(N) {
    INT(sz);
    VEC(P, e, sz);
    e = rearrange(e, hull(e));
    a.ep(e);
  }
  FOR(i, 1, N) {
    int sz = len(a[i]);
    FOR(k, sz) {
      int j = (k + 1) % sz;
      Z t = a[i - 1].convex_cut(a[i].ps[k], a[i].ps[j]);
      t = rearrange(t, hull(t));
      a[i - 1] = convex_polygon(t);
    }
    swap(a[i], a[i - 1]);
  }
  setp(3);
  print(a[N - 1].area() / 2.L);
}
```
)
#pagebreak()
=== P4360
- link: #link("https://www.luogu.com.cn/problem/P4360")
- 题意：挺短的，不写了

令 dp[i] 为最后一个选址在 $i$ 处的总 cost ，转移很显然，新的锯木厂会将一个区间分成两半，代价差值就是 dp 值变化量，注意到有决策单调性，直接分治。

#zebraw(
```cpp
using X = struct {
  int w, d, s;
};
X op(X a, X b) {
  return {a.w + b.w, a.d + b.d, a.s + b.s + a.w * b.d};
}
void Yorisou() {
  INT(N);
  vc<X> a(N);
  FOR(i, N) IN(a[i].w, a[i].d), a[i].s = a[i].w * a[i].d;
  FOR(i, 1, N) a[i] = op(a[i - 1], a[i]);
  a.insert(a.begin(), {0, 0, 0});
  Z w = [&](int l, int r) {
    if (l >= r) return 0;
    return a[r].s - a[l].s - a[l].w * (a[r].d - a[l].d);
  };
  vc<int> pr(N), dp(N, inf<int>);
  FOR(i, N) pr[i] = w(0, i) + w(i + 1, N);
  Z f = [&](Z &f, int l, int r, int ql, int qr) -> void {
    if (l > r) return;
    int m = (l + r) >> 1, id = -1, nr = min(qr, m - 1);
    int e = inf<int>;
    FOR(k, ql, nr + 1) {
      if (chmin(e, pr[k] - w(k + 1, N) +  w(k + 1, m) + w(m + 1, N))) id = k;
    }
    dp[m] = e;
    if (l < m) f(f, l, m - 1, ql, id);
    if (m < r) f(f, m + 1, r, id, qr);
  };
  f(f, 1, N - 1, 0, N - 2);
  print(QMIN(dp));
}
```
)
#pagebreak()
=== P3648
- link: #link("https://www.luogu.com.cn/problem/P3648")
- 题意：有一个序列，将其分成 K + 1 段，每次分割获得分割后两段和的乘积的分数，问最大得分以及方案

先列式子证明一下得分与操作顺序无关，令 dp[i] 为最后一次在 i 处分割的总得分，显然这个东西有决策单调性，就做完了

#zebraw(
```cpp
void Yorisou() {
  INT(N, K);
  VEC(ll, a, N);
  vc<ll> c = pre_sum(a);
  Z w = [&](int l, int r) { return c[r] - c[l]; };
  retsu<int> fa(K, N);
  vc<ll> dp(N), ndp(N);
  int ti = 0;
  FOR(i, N - 1) dp[i] = c[i + 1] *  w(i + 1, N), fa[0][i] = i;
  Z f = [&](Z &f, int l, int r, int ql, int qr) -> void {
    if (l > r) return;
    int m = (l + r) >> 1, id = -1, nr = min(qr, m - 1);
    ll e = -1;
    FOR(k, ql, nr + 1) {
      if (chmax(e, dp[k] + w(k + 1, m + 1) * (w(m + 1, N)))) id = k;
    }
    ndp[m] = e, fa[ti + 1][m] = id;
    if (l < m) f(f, l, m - 1, ql, id);
    if (m < r) f(f, m + 1, r, id, qr);
  };
  FOR(i, 1, K) {
    f(f, i, N - 1, i - 1, N - 2);
    dp.swap(ndp);
    ++ti;
  }
  vc<int> ans;
  int x = std::max_element(all(dp)) - dp.begin();
  print(dp[x]);
  FOR_R(i, K) {
    ans.ep(x + 1);
    x = fa[i][x];
  }
  reverse(ans);
  print(ans);
}
```
)
#pagebreak()
== 2025-12-09
=== P1527
- link: #link("https://www.luogu.com.cn/problem/P1527")
- 题意：给你一个 n×n 的矩阵，但是每次询问一个子矩形的第 k 小数。

整体二分，以权值为矩阵元素排序，check时顺序加入二维 fenw 中。
#zebraw(
```cpp
void Yorisou() {
  INT(N, Q);
  retsu<int> a(N, N);
  FOR(i, N) FOR(k, N) IN(a[i][k]);
  vc<int> f = a.A;
  unique(f);
  int sz = len(f);
  vc<vc<PII>> v(sz);
  FOR(i, N) FOR(k, N) v[lb(f, a[i][k])].ep(i, k);
  using dat = struct {
    int x, y, xx, yy, K, l, r;
  };
  vc<dat> q(Q);
  FOR(i, Q) {
    INT(x, y, xx, yy, K);
    --x, --y;
    q[i] = {x, y, xx, yy, K, sz - 1, -1};
  }
  vc<int> X(N * N), Y(N * N);
  FOR(i, N) FOR(k, N) X[i * N + k] = i, Y[i * N + k] = k;
  fenwfenw<monoid_add<int>> bit(N, N);
  vc<vc<int>> qs(sz + 1);
  while (1) {
    bool f = 0;
    FOR(i, sz) qs[i].clear();
    FOR(i, Q) {
      int l = q[i].l, r = q[i].r;
      if (abs(r - l) > 1) f = 1, qs[(l + r) >> 1].ep(i);
    }
    if (not f) break;
    bit.reset();
    FOR(i, sz) {
      for (Z [x, y] : v[i]) bit.multiply(x, y, 1);
      for (int id : qs[i]) {
        Z &[l, u, r, d, K, ql, qr] = q[id];
        if (bit.prod(l, r, u, d) >= K) ql = i;
        else qr = i;
      }
    }
  }
  FOR(i, Q) print(f[q[i].l]);
}
```
)
#pagebreak()
=== P1912
- link: #link("https://www.luogu.com.cn/problem/P1912")
决策单调性，cdq分治硬做
#zebraw(
```cpp
using RE = long double;
constexpr ll in = 1'000'000'000'000'000'000ll;
inline RE pw(RE a, ll k) {
  RE r = 1;
  FOR(k) r *= a;
  return r;
}
void Yorisou() {
  INT(N, L, P);
  VEC(string, s, N);
  vc<int> c(N);
  FOR(i, N) c[i] = len(s[i]);
  c = pre_sum(c);
  FOR(i, N) c[i + 1] += i + 1;
  vc<RE> dp(N + 1, -1);
  vc<int> fa(N + 1, -1);
  dp[0] = 0;
  Z f = [&](Z &f, int l, int r, int ql, int qr) -> void {
    if (l > r) return;
    int m = (l + r) >> 1, id = ql, nr = min(qr, m - 1);
    RE e = -1;
    FOR(k, ql, nr + 1) {
      RE nx = dp[k] + pw(std::abs(c[m] - c[k] - 1 - L), P);
      if (e == -1 or e > nx) e = nx, id = k;
    }
    if (dp[m] == -1 or e < dp[m]) dp[m] = e, fa[m] = id;
    f(f, l, m - 1, ql, id), f(f, m + 1, r, id, qr);
  };
  Z y = [&](Z &y, int l, int r) -> void {
    if (l == r) return;
    int m = (l + r) >> 1;
    y(y, l, m);
    f(f, m + 1, r, l, m);
    y(y, m + 1, r);
  };
  y(y, 0, N);
  if (dp[N] > in) {
    print("Too hard to arrange");
  } else {
    print((ll)dp[N]);
    vc<string> ans;
    int x = N;
    while (fa[x] != -1) {
      string str;
      FOR(i, fa[x], x) {
        str += s[i];
        str += ' ';
      }
      pop(str);
      ans.ep(str);
      x = fa[x];
    }
    reverse(ans);
    for (Z &s : ans) print(s);
  }
  print("--------------------");
}
```
)
#pagebreak()
=== P2178
- link: #link("https://www.luogu.com.cn/problem/P2178")
- 题意：求一个串的所有后缀的，lcp为 i 的 pair 数，以及每种 pair 中权值乘积最大的乘积

SA 然后并查集合并信息
#zebraw(
```cpp
struct X {
  bool ze;
  ll a[4];
};
struct MX {
  using X = ::X;
  static constexpr X op(const X &L, const X &R) {
    X res = L;
    res.ze |= R.ze;
    chmax(res.a[0], R.a[0]);
    chmax(res.a[2], R.a[2]);
    chmin(res.a[1], R.a[1]);
    chmin(res.a[3], R.a[3]);
    return res;
  }
  static constexpr X unit() {
    return {0, {-inf<ll>, inf<ll>, -inf<ll>, inf<ll>}};
  }
  static ll f(ll x, ll y) {
    if (max(x, y) == inf<ll>) return -inf<ll>;
    if (min(x, y) == -inf<ll>) return -inf<ll>;
    return x * y;
  }
  static ll f(const X &L, const X &R) {
    ll s = -inf<ll>;
    FOR(i, 4) FOR(k, 4) chmax(s, f(L.a[i], R.a[k]));
    if (L.ze or R.ze) chmax(s, 0);
    return s;
  }
};
void Yorisou() {
  INT(N);
  STR(s);
  VEC(int, a, N);
  SA sa(s);
  vc<PII> e;
  FOR(i, N - 1) if (sa.lcp[i]) e.ep(sa.lcp[i], i);
  sort(e, greater());
  dsu_monoid<MX> g(N, [&](int i) {
    Z r = MX::unit();
    ll x = a[sa.sa[i]];
    if (x > 0) r.a[0] = r.a[1] = x;
    else if (x < 0) r.a[2] = r.a[3] = x;
    else r.ze = 1;
    return r;
  });
  vc<ll> c(N), mx(N, -inf<ll>);
  for (Z [w, i] : e) {
    int x = i, y = i + 1;
    x = g[x].fi, y = g[y].fi;
    if (x == y) continue;
    c[w] += 1ll * g.size(x) * g.size(y);
    chmax(mx[w], MX::f(g[x].se, g[y].se));
    g.merge(x, y);
  }
  FOR_R(i, N - 1) c[i] += c[i + 1];
  FOR_R(i, N - 1) chmax(mx[i], mx[i + 1]);
  vc<ll> A, B;
  for (int x : a) (x < 0 ? A : B).ep(x);
  sort(A), sort(B);
  ll r = 0;
  FOR(i, len(A) - 1) chmax(r, A[i] * A[i + 1]);
  FOR(i, len(B) - 1) chmax(r, B[i] * B[i + 1]);
  if (len(A) and len(B)) 
    chmax(r, max(A[0] * B.back(), A.back() * B[0]));
  print(1ll * N * (N - 1) / 2, r);
  FOR(i, 1, N) {
    if (not c[i]) print(0, 0);
    else print(c[i], mx[i]);
  }
}
```
)

=== P3232
- link: #link("https://www.luogu.com.cn/problem/P3232")
随机游走板子
#zebraw(
```cpp
using RE = long double;
using MT = matrix_op<RE>;
using X = MT::X;
constexpr RE eps = 1e-12;
bool f(RE x) { return std::abs(x) <= eps; }
X solve(X A, vc<RE> B = {}) {
  const int N = len(A), M = len(A[0]);
  if (B.empty()) B.resize(N, 0);
  assert(N == len(B));
  int rk = 0;
  FOR(j, M) {
    if (rk == N) break;
    FOR(i, rk, N) if (not f(A[i][j])) {
      swap(A[rk], A[i]);
      swap(B[rk], B[i]);
      break;
    }
    if (f(A[rk][j])) continue;
    RE c = RE(1) / A[rk][j];
    for (RE &x : A[rk]) x *= c;
    B[rk] *= c;
    FOR(i, N) if (i != rk) {
      RE c = A[i][j];
      if (f(c)) continue;
      B[i] -= B[rk] * c;
      FOR(k, j, M) { A[i][k] -= A[rk][k] * c; }
    }
    ++rk;
  }
  FOR(i, rk, N) if (not f(B[i])) return {};
  vc<vc<RE>> res(1, vc<RE>(M));
  vc<int> pv(M, -1);
  int p = 0;
  FOR(i, rk) {
    while (f(A[i][p])) ++p;
    res[0][p] = B[i];
    pv[p] = i;
  }
  FOR(j, M) if (pv[j] == -1) {
    vc<RE> x(M);
    x[j] = -1;
    FOR(k, j) if (pv[k] != -1) x[k] = A[pv[k]][j];
    res.ep(x);
  }
  return res;
}
void Yorisou() {
  INT(N, M);
  vc<int> in(N);
  VEC(PII, e, M);
  for (Z &[x, y] : e) {
    --x, --y;
    ++in[x], ++in[y];
  }
  MT::X a = MT::make(N, N);
  vc<RE> b(N);
  FOR(i, N) a[i][i] = 1;
  b[0] = 1;
  for (Z [x, y] : e) {
    if (x != N - 1 and y != N - 1) {
      a[x][y] -= RE(1) / in[y];
      a[y][x] -= RE(1) / in[x];
    }
  }
  vc<RE> r = solve(a, b)[0];
  vc<RE> c(M);
  FOR(i, M) {
    Z [x, y] = e[i];
    if (x != N - 1) c[i] += r[x] / in[x];
    if (y != N - 1) c[i] += r[y] / in[y];
  }
  sort(c, greater());
  RE ans = 0;
  FOR(i, M) ans += (i + 1) * c[i];
  setp(3);
  print(ans);
}
```
)

=== P3292
- link: #link("https://www.luogu.com.cn/problem/P3292")
树剖套st表求树链上线性基
#zebraw(
```cpp
void Yorisou() {
  INT(N, Q);
  VEC(ll, a, N);
  graph g(N);
  g.read_tree();
  tree v(g);
  tree_monoid_ST<decltype(v), monoid_vector_space<ll>> seg(v, [&](int i) {
    return vector_space<ll>({a[i]}, 0);
  });
  FOR(Q) {
    INT(x, y);
    --x, --y;
    print(seg.prod_path(x, y).get_max());
  }
}
```
)

#pagebreak()
=== P3515
- link: #link("https://www.luogu.com.cn/problem/P3515")
决策单调性
#zebraw(
```cpp
using RE = double;
void Yorisou() {
  INT(N);
  VEC(int, a, N);
  vc<RE> dp(N), s(N);
  FOR(i, 1, N) s[i] = sqrtl(i);
  Z f = [&](Z &f, int l, int r, int ql, int qr) -> void {
    if (l > r) return;
    int m = (l + r) >> 1, id = -1, nr = min(qr, m - 1);
    RE e = -inf<RE>;
    FOR(k, ql, nr + 1) if (chmax(e, a[k] - a[m] + s[abs(k - m)])) id = k;
    chmax(dp[m], e);
    if (l < m) f(f, l, m - 1, ql, id);
    if (m < r) f(f, m + 1, r, id, qr);
  };
  f(f, 1, N - 1, 0, N - 2);
  vc<RE> t = dp;
  reverse(a);
  fill(all(dp), 0);
  f(f, 1, N - 1, 0, N - 2);
  reverse(dp);
  FOR(i, N) print((int)std::ceil(max(dp[i], t[i])));
}
```
)
#pagebreak()
=== P3810
- link: #link("https://www.luogu.com.cn/problem/P3810")
三维偏序，使用小波矩阵套树状数组实现在线二维数点求解
#zebraw(
```cpp
using wave = wave_matrix_2d<int, 0, 0, fenw01>;
void Yorisou() {
  INT(N, K);
  VEC(T3<int>, a, N);
  vc<vc<int>> v(K);
  FOR(i, N) {
    Z &[x, y, z] = a[i];
    --x, --y, --z;
    v[x].ep(i);
  }
  wave g(N, [&](int i) -> T3<int> {
    Z [x, y, z] = a[i];
    return {y, z, 0};
  });
  vc<int> ans(N);
  FOR(k, K) {
    for (int i : v[k]) g.multiply(i, 1);
    for (int i : v[k]) {
      Z [x, y, z] = a[i];
      ++ans[g.pre_prod(0, y + 1, z + 1) - 1];
    }
  }
  FOR(i, N) print(ans[i]);
}
```
)
#pagebreak()
=== P4197
- link: #link("https://www.luogu.com.cn/problem/P4197")
建立重构树，二分找到最远的合法祖先，问题变为求连续一段叶子的 kth ，按 dfn 建立小波矩阵，二分左右端点求解。
#zebraw(
```cpp
void Yorisou() {
  INT(N, M, Q);
  VEC(int, h, N);
  VEC(T3<int>, e, M);
  for (Z &[x, y, w] : e) {
    --x, --y;
    swap(x, w);
  }
  sort(e);
  dsu f(N + N - 1);
  graph g(N + N - 1);
  vc<int> val(N + N - 1);
  int nt = N;
  for (Z [w, x, y] : e) {
    x = f[x], y = f[y];
    if (x != y) {
      g.add(nt, x);
      g.add(nt, y);
      f.set(nt, x);
      f.set(nt, y);
      val[nt] = w;
      ++nt;
    }
  }
  if (nt != N + N - 1) {
    FOR(i, nt) if (f[nt] != f[i]) {
      g.add(nt, f[i]);
      f.set(nt, f[i]);
    }
    val[nt++] = inf<int>;
  }
  g.build();
  tree v(g, nt - 1);
  vc<int> I(N);
  FOR(i, N) I[i] = v.L[i];
  vc<int> t = argsort(I);
  h = rearrange(h, t);
  I = rearrange(I, t);
  wave_matrix_sim wm(h);
  FOR(Q) {
    INT(x, lm, K);
    --x;
    x = v.max_path([&](int x) { return val[x] <= lm; }, x, N + N - 2);
    int l = lb(I, v.L[x]), r = lb(I, v.R[x]);
    if (r - l < K) print(-1);
    else print(wm.kth(l, r, r - l - K));
  }
}
```
)
#pagebreak()
=== P4254
- link: #link("https://www.luogu.com.cn/problem/P4254")
CHT 模板
#zebraw(
```cpp
using RE = double;
void Yorisou() {
  INT(N);
  CHT<RE> g;
  g.add(0, 0);
  FOR(N) {
    STR(op);
    if (op[0] == 'P') {
      REAL(b, a);
      b -= a;
      g.add(a, b);
    } else {
      INT(x);
      print(ll(g.f(x) / 100));
    }
  }
}
```
)
#pagebreak()
=== P4839
- link: #link("https://www.luogu.com.cn/problem/P4839")
单点修改，区间线性基查询，使用了常数较小的写法
#zebraw(
```cpp
struct Seg {
  struct X {
    vc<int> a;
    void add(int x) {
      for (int y : a) chmin(x, x ^ y);
      if (x) a.ep(x);
    }
  };
  vc<X> a;
  int N, log, sz;
  Seg(int M) {
    N = M, log = 1;
    while ((1 << log) < N) ++log;
    sz = 1 << log;
    a.resize(sz << 1);
  }
  
  void upd(int i, int x) {
    a[i += sz].add(x);
    while (i >>= 1) a[i].add(x);
  }

  int prod(int l, int r) {
    l += sz, r += sz;
    X x;
    while (l < r) {
      if (l & 1) for (int e : a[l++].a) x.add(e);
      if (r & 1) for (int e : a[--r].a) x.add(e);
      l >>= 1, r >>= 1;
    }
    for (r = 0; int e : x.a) chmax(r, r ^ e);
    return r;
  }
};
void Yorisou() {
  INT(Q, N);
  Seg seg(N);
  FOR(Q) {
    INT(op);
    if (op == 1) {
      INT(i, x);
      --i;
      seg.upd(i, x);
    } else {
      INT(l, r);
      --l;
      print(seg.prod(l, r));
    }
  }
}
```
)
#pagebreak()
=== P5503
- link: #link("https://www.luogu.com.cn/problem/P5503")
决策单调性
#zebraw(
```cpp
using RE = double;
void Yorisou() {
  INT(N);
  VEC(int, a, N);
  vc<RE> dp(N), s(N);
  FOR(i, 1, N) s[i] = sqrtl(i);
  Z f = [&](Z &f, int l, int r, int ql, int qr) -> void {
    if (l > r) return;
    int m = (l + r) >> 1, id = -1, nr = min(qr, m - 1);
    RE e = -inf<RE>;
    FOR(k, ql, nr + 1) if (chmax(e, a[k] - a[m] + s[abs(k - m)])) id = k;
    chmax(dp[m], e);
    if (l < m) f(f, l, m - 1, ql, id);
    if (m < r) f(f, m + 1, r, id, qr);
  };
  f(f, 1, N - 1, 0, N - 2);
  vc<RE> t = dp;
  reverse(a);
  fill(all(dp), 0);
  f(f, 1, N - 1, 0, N - 2);
  reverse(dp);
  FOR(i, N) print((int)std::ceil(max(dp[i], t[i])));
}
```
)
#pagebreak()
=== P10689
- link: #link("https://www.luogu.com.cn/problem/P10689")
treap 板子
#zebraw(
```cpp
using AM = a_monoid_min_add<int>;
void Yorisou() {
  INT(N);
  VEC(int, a, N);
  treap_act<AM> seg;
  INT(M);
  Z t = seg.newnode(a);
  FOR(M) {
    STR(op);
    if (op == "ADD") {
      INT(l, r, x);
      --l;
      t = seg.apply(t, l, r, x);
    } else if (op == "REVERSE") {
      INT(l, r);
      --l;
      t = seg.reverse(t, l, r);
    } else if (op == "REVOLVE") {
      INT(l, r, x);
      --l;
      x %= r - l;
      if (x == 0) continue;
      t = seg.reverse(t, l, r);
      t = seg.reverse(t, l, l + x);
      t = seg.reverse(t, l + x, r);
    } else if (op == "INSERT") {
      INT(x, w);
      Z [a, b] = seg.split(t, x);
      Z np = seg.newnode(w);
      t = seg.merge(a, np, b);
    } else if (op == "DELETE") {
      INT(x);
      --x;
      Z [a, mid, b] = seg.split(t, x, x + 1);
      t = seg.merge(a, b);
    } else if (op == "MIN") {
      INT(l, r);
      --l;
      print(seg.prod(t, l, r));
    }
  }
}
```
)
#pagebreak()
=== P11620
- link: #link("https://www.luogu.com.cn/problem/P11620")
差分后转为单点修改区间线性基查询
#zebraw(
```cpp
using bs = vector_space<int>;
void Yorisou() {
  INT(N, Q);
  VEC(int, a, N);
  vc<int> b(N);
  FOR(i, 1, N) b[i] = a[i] ^ a[i - 1];
  dual_seg<monoid_xor<int>> s(N);
  Seg<monoid_vector_space<int>> seg(N, [&](int i) {
    bs x;
    x.add(b[i]);
    return x;
  });
  FOR(Q) {
    INT(op, l, r, x);
    --l;
    if (op == 1) {
      s.apply(l, r, x);
      bs nx;
      nx.add(b[l] ^= x);
      seg.set(l, nx);
      nx.a.clear();
      if (r != N) nx.add(b[r] ^= x), seg.set(r, nx);
    } else {
      bs e = l == r ? bs() : seg.prod(l + 1, r);
      e.add(s.get(l) ^ a[l]);
      print(e.get_max(x));
    }
  }
}
```
)
#pagebreak()
=== P14513
- link: #link("https://www.luogu.com.cn/problem/P14513")
小波矩阵二分
#zebraw(
```cpp
struct bitvec {
  int N;
  vc<pair<ull, uint>> s;
  bitvec(int N = 0) : N(N), s((N + 127) >> 6) {}

  void set(int i) { s[i >> 6].fi |= 1ull << (i & 63); }

  void build() {
    int N = len(s) - 1;
    FOR(i, N) s[i + 1].se = s[i].se + pc(s[i].fi);
  }

  int rank(int k, bool f = 1) const {
    Z [a, b] = s[k >> 6];
    int r = b + pc(a & ((1ull << (k & 63)) - 1));
    return f ? r : k - r;
  }
};
struct DIS {
  vc<int> f;
  vc<int> build(vc<int> a) {
    f = a;
    unique(f);
    for (int &x : a) x = lb(f, x);
    return a;
  }
  int operator[](int x) { return lb(f, x); }
};
using std::move;
struct wave_mat {
  int N, log, sz;
  DIS d;
  vc<int> mid;
  vc<bitvec> bit, bbit;

  void build(vc<int> y, vc<int> yy) {
    N = len(y);
    vc<int> a = d.build(y), aa = yy;
    for (int &x : aa) x = d[x];
    sz = QMAX(a) + 1;

    log = 0;
    while ((1 << log) < sz) ++log;
    mid.resize(log);
    bit.assign(log, bitvec(N));
    bbit.assign(log, bitvec(N));

    vc<int> b(N), bb(N);
    FOR_R(k, log) {
      int p = 0, pp = 0;
      FOR(i, N) {
        if (a[i] >> k & 1) bit[k].set(i), bb[pp++] = a[i];
        else b[p++] = a[i];
      }
      swap(a, b);
      move(bb.begin(), bb.begin() + pp, a.begin() + p);
      mid[k] = p;
      bit[k].build();
    }
    FOR_R(k, log) {
      int p = 0, pp = 0;
      FOR(i, N) {
        if (aa[i] >> k & 1) bbit[k].set(i), bb[pp++] = aa[i];
        else b[p++] = aa[i];
      }
      swap(aa, b);
      move(bb.begin(), bb.begin() + pp, aa.begin() + p);
      bbit[k].build();
    }
  }

  int rank(int L, int R, int y) {
    int p = d[y];
    if (L == R or p == 0) return 0;
    if (p == sz) return R - L;
    int c = 0;
    FOR_R(i, log) {
      int l = bit[i].rank(L, 0), r = bit[i].rank(R, 0);
      int ll = L + mid[i] - l, rr = R + mid[i] - r;
      if (p >> i & 1) c += r - l, L = ll, R = rr;
      else L = l, R = r;
    }
    return c;
  }

  int rrk(int L, int R, int y) {
    int p = d[y];
    if (L == R or p == 0) return 0;
    if (p == sz) return R - L;
    int c = 0;
    FOR_R(i, log) {
      int l = bbit[i].rank(L, 0), r = bbit[i].rank(R, 0);
      int ll = L + mid[i] - l, rr = R + mid[i] - r;
      if (p >> i & 1) c += r - l, L = ll, R = rr;
      else L = l, R = r;
    }
    return c;
  }

  int bina(int L, int R, int L2, int R2, int K) {
    int c = 0, p = 0;
    FOR_R(i, log) {
      int l1 = bit[i].rank(L, 0), r1 = bit[i].rank(R, 0);
      int ll1 = L + mid[i] - l1, rr1 = R + mid[i] - r1;
      int cc = c + r1 - l1;
      int pp = p | 1 << i;
      int l2 = bbit[i].rank(L2, 0), r2 = bbit[i].rank(R2, 0);
      int ll2 = L2 + mid[i] - l2, rr2 = R2 + mid[i] - r2;
      cc -= r2 - l2;
      if (cc < K) {
        tie(p, c, L, R, L2, R2) = {pp, cc, ll1, rr1, ll2, rr2};
      } else {
        tie(L, R, L2, R2) = {l1, r1, l2, r2};
      }
    }
    return d.f[p];
  }
};
T4<vc<int>> work(int N) {
  vc<PII> ls(N), rs(N);
  FOR(i, N) {
    INT(l, r, w);
    ls[i] = {l, w}, rs[i] = {r + 1, w};
  }
  sort(ls), sort(rs);
  vc<int> pl(N), pr(N), wl(N), wr(N);
  FOR(i, N) {
    tie(pl[i], wl[i]) = ls[i];
    tie(pr[i], wr[i]) = rs[i];
  }
  ls.clear(), ls.shrink_to_fit();
  rs.clear(), rs.shrink_to_fit();
  return {std::move(pl), std::move(pr), std::move(wl), std::move(wr)};
}
void Yorisou() {
  INT(N, Q);
  Z [pl, pr, wl, wr] = work(N);
  wave_mat wm;
  wm.build(wl, wr);
  int ans = 0;
  FOR(Q) {
    INT(x, y);
    x ^= ans, y ^= ans;
    int l = ub(pl, x), r = ub(pr, x);
    int k = wm.rank(0, l, y + 1) - wm.rrk(0, r, y + 1);
    ans = k == 0 ? 0 : wm.bina(0, l, 0, r, k);
    print(ans);
    ans &= (1 << 21) - 1;
  }
}
```
)