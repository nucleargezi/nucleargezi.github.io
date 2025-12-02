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
== P4767
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
== P1552
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
== P4051
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
== P2473
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
== P2596
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
== P3527
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
  INT(Q);
  VEC(T3<int>, q, Q);
  
  vc<vc<int>> qs(Q + 1);
  vc<PII> res(N, {Q, -1});
  BIT seg(M);
  while (1) {
    bool f = 0;
    FOR(i, Q) qs[i].clear();
    FOR(i, N) {
      Z [l, r] = res[i];
      if (abs(r - l) > 1) f = 1, qs[(l + r) >> 1].ep(i);
    }
    if (not f) break;
    seg.build(M);
    FOR(i, Q) {
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
    if (l == Q) NIE();
    else print(l + 1);
  }
}
```
)
#pagebreak()
== P4196
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
== P4360
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
== P3648
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