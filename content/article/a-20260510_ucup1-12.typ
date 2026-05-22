#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 1st Universal Cup. Stage 12: Ōokayama",
  desc: [ucup 1-12 训练记录],
  date: "2026-05-10",
  tags: ("icpc",),
  category: "ICPC",
)

= The 1st Universal Cup. Stage 12: Ōokayama

#link("https://qoj.ac/contest/2071", "Qoj Link")

== Hitokoto

神秘柜子校赛

== A. XOR Tree Path
- In-Contest Solves: 138/150 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6317")

=== Formal Problem Statement

给定一棵有 $N$ 个顶点的有根树, 顶点编号为 $1, 2, ..., N$, 根为顶点 $1$

第 $i$ 个顶点的颜色由 $A_i$ 表示, 若 $A_i = 0$ 则为白色, 若 $A_i = 1$ 则为黑色

你可以进行任意多次操作, 每次选择一个叶子顶点 $x$, 并将从根到 $x$ 的简单路径上所有顶点的颜色翻转

翻转指将白色变为黑色, 将黑色变为白色

求经过若干次操作后, 树上黑色顶点数量的最大值

=== Constraints

- $2 <= N <= 10^5$
- $0 <= A_i <= 1$
- $1 <= U_i, V_i <= N$

=== Solution

自下而上 dp 每个点被操作次数为奇数和偶数的情况, 合并时转换奇偶取转换代价最小的子节点

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/gg/make_rooted.hpp"

void Yorisou() {
  INT(N);
  VEC(int, a, N);
  vc<vc<int>> g(N);
  FOR(N - 1) {
    INT(a, b);
    --a, --b;
    g[a].ep(b);
    g[b].ep(a);
  }
  make_rooted(g, 0);
  Z f= [&](Z &f, int n) -> PII {
    int sz = si(g[n]);
    if (sz == 0) {
      PII rs = {0, 1};
      if (a[n]) swap(rs.fi, rs.se);
      return rs;
    } else {
      vc<int> d;
      int e = 0, c = 0;
      for (int x : g[n]) {
        var [a, b] = f(f, x);
        e += max(a, b);
        c += b >= a;
        d.ep(abs(a - b));
      }
      int m = QMIN(d);
      if (c & 1) return {e + a[n] - m, e + not a[n]};
      return {e + a[n], e + not a[n] - m};
    }
  };
  Z [x, y] = f(f, 0);
  print(max(x, y));
}

int main() {
  Yorisou();
  return 0;
}
```

== B. Magical Wallet
- In-Contest Solves: 136/167 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6318")

=== Formal Problem Statement

你有一个初始金额为 $X$ 日元的魔法钱包

在任意时刻, 你可以使用任意多次魔法, 将钱包当前金额的十进制表示中的所有数字任意重排, 重排后若有前导零则忽略

接下来依次经过 $N$ 家商店, 第 $i$ 家商店出售价格为 $A_i$ 日元的商品

当到达第 $i$ 家商店时, 若钱包中的金额不小于 $A_i$, 则可以支付 $A_i$ 日元购买该商品, 钱包金额减少 $A_i$

求最多可以买到多少件商品

=== Constraints

- $1 <= N <= 100$
- $1 <= X < 10^4$
- $1 <= A_i < 10^4$

=== Solution

值域很小, 暴力 dp

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/ds/basic/retsu.hpp"

void Yorisou() {
  INT(N, K);
  VEC(int, a, N);
  retsu<int> dp(N + 1, 10000, -1);
  vc<int> s;
  while (K) s.ep(K % 10), K /= 10;
  sort(s);
  do {
    int n = 0;
    for (int x : s) n = n * 10 + x;
    dp[0][n] = 0;
  } while (next_permutation(all(s)));
  FOR(i, N) {
    int x = a[i];
    vc<int> s;
    FOR(k, 10000) if (dp[i][k] != -1) {
      int f = dp[i][k];
      chmax(dp[i + 1][k], f);
      s.clear();
      int e = k;
      while (e) s.ep(e % 10), e /= 10;
      sort(s);
      do {
        int n = 0;
        for (int e : s) n = n * 10 + e;
        if (n >= x) chmax(dp[i + 1][n - x], f + 1);
      } while (next_permutation(all(s)));
    }
  }
  int rs = 0;
  FOR(i, 10000) chmax(rs, dp[N][i]);
  print(rs);
}

int main() {
  Yorisou();
  return 0;
}
```

== E. Five Med Sum
- In-Contest Solves: 135/185 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6321")

=== Formal Problem Statement

给定五个长度为 $N$ 的整数序列 $A, B, C, D, E$

记 $med(a, b, c, d, e)$ 为五个数 $a, b, c, d, e$ 的中位数, 即排序后第 $3$ 小的数

求下式对 $998244353$ 取模后的值

$ sum_(i=1)^N sum_(j=1)^N sum_(k=1)^N sum_(l=1)^N sum_(m=1)^N med(A_i, B_j, C_k, D_l, E_m) $

=== Constraints

- $1 <= N <= 10^5$
- $0 <= A_i, B_i, C_i, D_i, E_i < 998244353$

=== Solution

对每个中位数硬算方案加起来

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/mod/mint_t.hpp"

using mint = M99;
void Yorisou() {
  INT(N);
  vc<int> a[5];
  FOR(i, 5) {
    a[i].resize(N);
    IN(a[i]);
    sort(a[i]);
  }
  vc<int> f;
  FOR(i, 5) for (int x : a[i]) f.ep(x);
  unique(f);
  int sz = si(f);
  FOR(i, 5) for (int &x : a[i]) x = lb(f, x);
  vc<vc<int>> g(sz);
  FOR(i, 5) for (int x : a[i]) g[x].ep(i);

  Z prod = [&](int i, int l, int r) -> mint {
    return lb(a[i], r) - lb(a[i], l);
  };
  
  bool vis[5]{};
  mint rs = 0;
  FOR(i, sz) {
    unique(g[i]);
    int sm = si(g[i]);
    vc<int> I;
    FOR(s, 1, 1 << sm) {
      I.clear();
      FOR(k, sm) if (s >> k & 1) vis[g[i][k]] = 1;
      FOR(i, 5) {
        if (not vis[i]) I.ep(i);
        else vis[i] = 0;
      }

      int ls = 5 - pc(s);
      mint ad = 1;
      FOR(k, sm) if (s >> k & 1) ad *= prod(g[i][k], i, i + 1);
      FOR(ms, 1 << ls) {
        int p = pc(ms);
        if (p < 3 and ls - p < 3) {
          mint go = ad;
          FOR(k, ls) {
            if (ms >> k & 1) go *= prod(I[k], 0, i);
            else go *= prod(I[k], i + 1, sz);
          }
          rs += go * f[i];
        }
      }
    }
  }
  print(rs);
}

int main() {
  Yorisou();
  return 0;
}
```

== G. Range NEQ
- In-Contest Solves: 97/133 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6323")

=== Formal Problem Statement

给定两个正整数 $N, M$

考虑所有 $(0, 1, ..., N M - 1)$ 的排列 $P = (P_0, P_1, ..., P_(N M - 1))$

要求对所有满足 $0 <= i < N M$ 的整数 $i$, 都有 $floor(i / M) != floor(P_i / M)$

求满足条件的排列数量, 对 $998244353$ 取模

=== Constraints

- $2 <= N <= 1000$
- $1 <= M <= 1000$

=== Solution

赛时怎么过穿了, 人人都会多项式

每类位置有一类禁止的值, 可以计算 强制选中 k 个非法匹配, 剩下任意匹配 的方案数, 进行容斥

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/poly/fps_pow.hpp"

using mint = M99;
using fps = vc<mint>;
fps_t<mint> X;
void Yorisou() {
  INT(N, M);
  fps f(N * M + 1);
  FOR(i, M + 1) f[i] = X.C(M, i) * X.fac(M) * X.ifac(M - i);
  f = X.pow(f, N);
  mint s;
  FOR(i, N * M + 1) {
    mint ad = f[i] * X.fac(N * M - i);
    if (i & 1) s -= ad;
    else s += ad;
  }
  print(s);
}

int main() {
  Yorisou();
  return 0;
}
```

== J. Make Convex Sequence
- In-Contest Solves: 88/202 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6326")

=== Formal Problem Statement

给定两个长度为 $N$ 的整数序列 $L, R$

需要判定是否存在一个长度为 $N$ 的实数序列 $A$, 满足以下条件

对所有 $1 <= i <= N$, 有 $L_i <= A_i <= R_i$

对所有 $2 <= i <= N - 1$, 有 $A_(i - 1) + A_(i + 1) >= 2 A_i$

若存在这样的序列 $A$, 输出 `Yes`, 否则输出 `No`

=== Constraints

- $3 <= N <= 3 times 10^5$
- $1 <= L_i <= R_i <= 10^9$

=== Solution

对上边界求凸壳, 凸壳就是最靠上的合法序列, 查看是否在下边界上面

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/ge/basic/hull.hpp"
#include "YRS/ge/basic/convex_polygon.hpp"

using P = point<ll>;
void Yorisou() {
  INT(N);
  VEC(int, a, N);
  VEC(int, b, N);
  vc<P> p(N);
  FOR(i, N) p[i] = {i, b[i]};
  p.ep(0, inf<int> / 2);
  p.ep(N - 1, inf<int> / 2);
  convex_polygon g(rearrange(p, hull(p)));
  FOR(i, N) {
    P c = {i, a[i]};
    if (g.side(c) == 1) return print("No");
  }
  print("Yes");
}

int main() {
  Yorisou();
  return 0;
}
```

== M. Colorful Graph
- In-Contest Solves: 60/332 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6329")

=== Formal Problem Statement

给定一张有 $N$ 个顶点和 $M$ 条边的有向图, 顶点编号为 $1, 2, ..., N$

第 $i$ 条边从顶点 $A_i$ 指向顶点 $B_i$

需要为每个顶点染上一种颜色, 颜色编号可以为 $1, 2, ..., N$

设顶点 $i$ 的颜色为 $c_i$, 对任意满足 $1 <= i < j <= N$ 且 $c_i = c_j$ 的点对 $(i, j)$, 必须存在一条从 $i$ 到 $j$ 的有向路径, 或存在一条从 $j$ 到 $i$ 的有向路径

在满足条件的所有染色方案中, 需要最小化 $max(c_1, c_2, ..., c_N)$

构造并输出任意一种满足上述最优性的染色方案

=== Constraints

- $1 <= N <= 7 times 10^3$
- $0 <= M <= 7 times 10^3$
- $1 <= A_i, B_i <= N$
- $A_i != B_i$
- $(A_i, B_i) != (A_j, B_j)$ for $1 <= i < j <= M$

=== Solution

卡空间, 赛时炸了很多发

首先处理掉图中的环, scc 缩点成一张 dag , 然后问题实际上就是求这张 dag 的最少路径覆盖, 可以用最大流解决

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/ds/basic/queue.hpp"
#include "YRS/flow/max_flow.hpp"

struct dsu {
  using ll = short;
  vc<ll> fa;
  dsu(ll N) : fa(N, -1) {}
  ll f(ll x) {
    while (fa[x] >= 0) {
      ll p = fa[fa[x]];
      if (p < 0) return fa[x];
      x = fa[x] = p;
    }
    return x;
  }
  ll operator[](ll x) { return f(x); }
  bool merge(ll a, ll b) {
    a = f(a) ,b = f(b);
    if (a == b) return 0;
    if (fa[a] > fa[b]) swap(a, b);
    fa[a] += fa[b];
    fa[b] = a;
    return 1;
  }
};

TE pair<short, vc<short>> scc(vc<vc<T>> &g) {
  short N = si(g), t = 0, c = 0;
  vc<short> a(N), b(N), id(N), s;
  Z f = [&](Z &f, short n) -> void {
    a[n] = b[n] = ++t;
    s.ep(n);
    for (short x : g[n]) {
      if (a[x]) chmin(b[n], a[x]);
      else f(f, x), chmin(b[n], b[x]);
    }
    if (a[n] == b[n]) {
      short x = pop(s);
      for (; x != n; x = pop(s)) id[x] = c, a[x] = N;
      id[x] = c++, a[x] = N;
    }
  };
  FOR(n, N) if (not a[n]) f(f, n);
  FOR(i, N) id[i] = c - id[i] - 1;
  return {c, id};
}

TE vc<vc<short>> scc_dag(vc<vc<T>> &g, short c, const vc<short> &id) {
  vc<ull> es;
  short N = si(g);
  FOR(i, N) for (short x : g[i]) {
    if (id[i] != id[x]) es.ep(ull(id[i]) << 32 | id[x]);
  }
  unique(es);
  vc<vc<short>> ng(c);
  for (ull e : es) {
    uint f = e >> 32, t = e;
    ng[f].ep(t);
  }
  return ng;
}

Z dag_path_cover(vc<vc<short>> &v) {
  using ll = short;
  short N = si(v), s = N << 1, t = s | 1;
  max_flow<ll> FL(t + 1, s, t);
  FOR(i, N) {
    FL.add(s, i << 1 | 1, 1);
    FL.add(i << 1, t, 1);
    FL.add(i << 1, i << 1 | 1, inf<ll>);
  }
  FOR(f, N) {
    for (ll t : v[f]) FL.add(f << 1 | 1, t << 1, inf<ll>);
    v[f].clear();
    v[f].shrink_to_fit();
  }
  FL.flow();
  dsu g(N);
  for (var p : FL.path_decomposition()) {
    ll x = p[1], y = p[si(p) - 2];
    g.merge(x >> 1, y >> 1);
  }
  vc<short> ans(N, N);
  t = 0;
  FOR(i, N) if (g[i] == i) ans[i] = t++;
  FOR(i, N) if (g[i] != i) ans[i] = ans[g[i]];
  g.fa.clear();
  g.fa.shrink_to_fit();
  return ans;
}
void Yorisou() {
  using ll = short;
  LL(N, M);
  vc<vc<ll>> g(N);
  VEC(PII, es, M);
  vc<ll> in(N);
  for (Z &[a, b] : es) --a, --b, ++in[a];
  FOR(i, N) g[i].reserve(in[i]);
  for (var [a, b] : es) g[a].ep(b);
  
  Z [c, id] = scc(g);
  vc<vc<ll>> v(c);
  es.clear();
  FOR(i, N) for (ll x : g[i]) if (id[x] != id[i]) es.ep(id[i], id[x]);
  unique(es);
  es.shrink_to_fit();
  in.resize(c);
  in.shrink_to_fit();
  fill(all(in), 0);
  for (var [a, b] : es) ++in[a];
  FOR(i, c) v[i].reserve(in[i]);
  fill(all(in), 0);
  for (var [a, b] : es) v[a].ep(b), ++in[b];

  queue<ll> q(c);
  FOR(i, c) if (not in[i]) q.eb(i);
  vc<ll> V;
  V.reserve(c);
  while (si(q)) {
    ll n = pop(q);
    V.ep(n);
    for (ll x : v[n]) if (not --in[x]) q.eb(x);
  }
  in.clear();
  in.shrink_to_fit();
  q.q.clear();
  q.q.shrink_to_fit();
  vc<ll> L(c);
  FOR(i, c) L[V[i]] = i;
  FOR(i, N) g[i].clear();
  FOR(i, c, N) g[i].shrink_to_fit();
  FOR(i, c) {
    for (ll x : v[V[i]]) g[i].ep(L[x]);
    v[V[i]].clear();
    v[V[i]].shrink_to_fit();
  }
  v.clear();
  v.shrink_to_fit();
  
  Z cov = dag_path_cover(g);
  FOR(i, N) put(cov[L[id[i]]] + 1, " \n"[i + 1 == N]);
}

int main() {
  cin.tie(0)->sync_with_stdio(0);
  Yorisou();
  return 0;
}
```

== N. XOR Reachable
- In-Contest Solves: 78/129 (ucup)
- #link("https://oj.qiuly.org/contest/1207/problem/6330")

=== Formal Problem Statement

给定整数 $N, M, K$, 以及一张有 $N$ 个顶点和 $M$ 条边的无向图, 顶点编号为 $1, 2, ..., N$

第 $i$ 条边连接顶点 $A_i$ 和 $B_i$, 边权为非负整数 $C_i$

图中可能存在重边, 但不存在自环

给定 $Q$ 次询问, 第 $i$ 次询问给定整数 $D_i$

对每次询问, 求满足以下条件的整数对 $(u, v)$ 的数量

$1 <= u < v <= N$

只使用满足 $(C_j xor D_i) < K$ 的边 $j$, 可以从顶点 $u$ 到达顶点 $v$

=== Constraints

- $2 <= N <= 10^5$
- $1 <= M <= 10^5$
- $0 <= K < 2^30$
- $1 <= A_i < B_i <= N$
- $0 <= C_i < 2^30$
- $1 <= Q <= 10^5$
- $0 <= D_i < 2^30$

=== Solution

看起来非常像线段树分治解决的那种问题, 可以用类似的方法进行分治, 将边和询问递归下去, 用可撤销并查集维护连通性

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/ds/rb/rb_dsu.hpp"

using dsu = rb_dsu;
void Yorisou() {
  INT(N, M, K);
  VEC(T3<int>, es, M);
  for (Z &[a, b, w] : es) --a, --b;

  INT(Q);
  VEC(int, q, Q);
  vc<int> I(Q);
  iota(all(I), 0);
  vc<int> EI(M);
  iota(all(EI), 0);

  dsu g(N);
  vc<ll> ans(Q);
  ll sm = 0;
  Z ae = [&](const vc<int> &I) {
    for (int i : I) {
      Z [a, b, _] = es[i];
      a = g[a], b = g[b];
      if (a != b) {
        sm += g.size(a) * g.size(b);
        g.merge(a, b);
      }
    }
  };

  Z f = [&](Z &f, int d, const vc<int> &EI, const vc<int> &I) -> void {
    if (I.empty()) return;
    if (EI.empty()) {
      for (int i : I) ans[i] = sm;
      return;
    }
    int t = g.time();
    ll cp = sm;
    vc<int> les, res;
    for (int i : EI) {
      Z [a, b, w] = es[i];
      if (w >> d & 1) res.ep(i);
      else les.ep(i);
    }
    vc<int> ls, rs;
    for (int i : I) {
      if (q[i] >> d & 1) rs.ep(i);
      else ls.ep(i);
    }
    if (K >> d & 1) {
      if (d) {
        ae(les);
        f(f, d - 1, res, ls);
        g.rb(t);
        sm = cp;
        ae(res);
        f(f, d - 1, les, rs);
      } else {
        ae(les);
        f(f, d - 1, {}, ls);
        g.rb(t);
        sm = cp;
        ae(res);
        f(f, d - 1, {}, rs);
      }
    } else {
      if (d) {
        f(f, d - 1, les, ls);
        f(f, d - 1, res, rs);
      } else {
        f(f, d - 1, {}, I);
      }
    }
    g.rb(t);
    sm = cp;
  };
  f(f, 29, EI, I);
  FOR(i, Q) print(ans[i]);
}

int main() {
  Yorisou();
  return 0;
}
```

// == A
// - In-Contest Solves:  (ucup)
// - #link(" ")

// === Formal Problem Statement

// === Solution

// === Implementation
// ```cpp

// ```
