#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 4th Universal Cup. Extra Stage 4: Chongqing",
  desc: [ucup 4-ex-4 训练记录],
  date: "2026-03-22",
  tags: ("icpc",),
  category: "ICPC",
)

= The 4th Universal Cup. Extra Stage 4: Chongqing 

#link("https://qoj.ac/contest/3387", "Qoj Link")

== Hitokoto

和队友组队 vp 的, 题目相当 dirt

== J. Tetris
- In-Contest Solves: 40/175 (ucup)
- #link("https://qoj.ac/contest/3387/problem/15428")

=== Formal Problem Statement

给定整数 $n, m, q$, 以及长度为 $m$ 的数组 $f$

存在一个无限序列 $g_1, g_2, dots$, 它由若干个长度为 $n$ 的排列块首尾连接而成；每一块都是 $1, 2, dots, n$ 的一个排列

需要判断哪些 $ r = x mod n in {0, 1, dots, n - 1} $ 是可能的. 也就是说, 是否存在某个非负整数 $x$ 满足 $x mod n = r$ , 并且存在一个合法的 $n$-BAG 序列 $g$ , 使得对所有 $1 <= i <= m$ 都满足：
- 若 $f_i = 0$, 则该位置没有约束；
- 若 $f_i != 0$, 则必须满足 $g_(x + i) = f_i$

对初始数组, 以及每次单点修改后的数组, 都要输出：
- 所有可行的 $r = x mod n$ 的数量；
- 这些可行 $r$ 的按位异或和

如果不存在任何可行的 $r$, 输出 `0 0`

=== Solution

从块与块的分割角度考虑这个问题, 将排列中的数字视为颜色, 当出现两个相同的颜色时, 它们之间一定至少出现了一次块与块的间隔, 如果他们的距离超过了一个块的大小, 这个东西构成不了什么限制, 否则它们一定位于两个相邻的块, 这样分割线一定要位于它们围成的区间内, 当然, 需要对 $n$ 取模, 区间形态也有可能因此被劈开

合法的分界线一定是处在所有的区间限制之中, 也就是所有区间的交, 所以需要一个结构来维护相邻区间的变化, 比如用 set 存所有颜色的位置, 插入和删除就是加入删除一系列相邻 segment

维护区间交可以记录一下区间总数, 每个区间用区间 $+1$ 来描述, 用动态开点线段树维护区间最值和数量, 如果最值不为总数, 则答案为 $0$

连续区间 $[L, R)$ 的异或值可以用差分求出, 而 $[0, N)$ 的异或值可以打表得到规律, 直接推也可以, 线段树区间初始化时带上这个值, 区间合并时若 max 相等则 xor 起来

=== Implementation

```cpp
struct def {
  ll ke(ll n) {
    int t = n & 3;
    if (t == 0) return n;
    if (t == 1) return 1;
    if (t == 2) return n + 1;
    return 0;
  }

  ll prod(ll l, ll r) { return ke(r - 1) ^ ke(l - 1); }

  MX::X dprod(ll l, ll r) { return {0, prod(l, r), r - l}; }
};

struct MX {
  struct X {
    ll mx, xo, c;
  };
  static X op(const X &a, const X &b) {
    if (a.mx == -1) return b;
    if (b.mx == -1) return a;
    if (a.mx == b.mx) return {a.mx, a.xo ^ b.xo, a.c + b.c};
    if (a.mx < b.mx) return {b.mx, b.xo, b.c};
    return {a.mx, a.xo, a.c};
  }
  static X unit() { return {-1, 0, 0}; }
};
struct MA {
  using X = int;
  static X op(X l, X r) { return l + r; }
  static X unit() { return 0; }
  static constexpr bool commute = 1;
};
struct AM {
  using MX = ::MX;
  using MA = ::MA;
  using X = MX::X;
  using A = MA::X;
  static constexpr X act(const X &x, const A &a, ll) {
    return {x.mx + a, x.xo, x.c};
  }
};

using DS = segdl_t<def, AM, 0, ll>;
using np = DS::np;
void Yorisou() {
  LL(N, M, Q);
  VEC(ll, f, M);
  hashmap<set<ll>> se(Q);
  DS seg(0, N);
  np t = seg.newnode();
  int gp = 0;

  Z add = [&](ll l, ll r, ll op = 1) {
    ll sz = r - l;
    if (sz >= N) return;
    ll st = (N - r % N) % N;
    gp += op;
    if (st + sz <= N) {
      t = seg.apply(t, st, st + sz, op);
    } else {
      t = seg.apply(t, st, N, op);
      t = seg.apply(t, 0, sz - (N - st), op);
    }
  };

  Z ins = [&](ll i, ll x) {
    if (x == 0) return;
    set<ll> &s = se[x];
    s.eb(i);
    Z it = s.find(i);
    if (it != s.bg() and next(it) != s.ed()) {
      Z l = prev(it), r = next(it);
      add(*l, *r, -1);
    }
    if (it != s.bg()) add(*prev(it), *it, 1);
    if (next(it) != s.ed()) add(*it, *next(it), 1);
  };

  Z del = [&](ll i, ll x) {
    if (x == 0 ) return;
    Z it = se[x].find(i);
    if (it == se[x].ed()) return;
    if (it != se[x].bg()) add(*prev(it), *it, -1);
    if (next(it) != se[x].ed()) add(*it, *next(it), -1);
    if (it != se[x].bg() and next(it) != se[x].ed())
      add(*prev(it), *next(it), 1);
    se[x].extract(it);
  };

  FOR(i, M) {
    ll x = f[i];
    ins(i, x);
  }
  
  Z out = [&]() {
    if (t->x.mx != gp) print(0, 0);
    else print(t->x.c, t->x.xo);
  };

  out();
  FOR(Q) {
    LL(i, x);
    --i;
    del(i, f[i]);
    ins(i, f[i] = x);
    out();
  }
}
```

== M. Reduction and Growth
- In-Contest Solves: 171/679 (ucup)
- #link("https://qoj.ac/contest/3387/problem/15431")

=== Formal Problem Statement

给一棵树, 初始根为 0, 值为 $a_0$, 接下来会不断用一个三元组 ${w, f, t}$ 给这个树加叶子, 从 f 到 t , 每经过一个点 $i$, 就令 $w = w / gcd(w, a_i)$ , 然后给点 t 新增一个叶子, 权值为 $w$

输出所有点的权值

=== Solution

树的结构是确定的, 可以先将树建出来, 考虑操作的本质, 对于 $w$ 的所有质因子的指数, 被路径上经过的点的对应质因数减损, 最终剩下的质因数的 prod 为权值

质因子数量是有限的, $e < sqrt(V)$ 的质因子只有不到 $200$ 个, 所以对于这些小的因子在树链的出现次数可以直接在树上维护前缀和来计算, 而大的质因子之多只有一个, 可以用一堆 set 存下已经出现的大质因子的 dfn , 查询时树剖拆出 log 个 dfn 段, 查询对应 set 在这些段中有没有出现

跑得飞快, 在 qoj 第一页

=== Implementation
```cpp
constexpr int sz = 1'000'000, B = 200;
vc<int> pt = ptable(sz), lpf = lpf_table(sz), to(sz, -1);
void Yorisou() {
  for (int t = 0; int x : pt) to[x] = t, t++;
  
  INT(N);
  vc<int> a(N);
  IN(a[0]);

  VEC(T3<int>, es, N - 1);
  graph g(N);
  vc<int> fa(N, -1);
  for (int t = 1; Z &[c, x, y] : es) {
    --x, --y;
    g.add(y, t);
    fa[t] = y;
    ++t;
  }
  g.build();
  hld v(g, 0);
  
  vc<array<int, B>> c(N);
  static set<int> se[200000];
  for (Z [e, p] : factor_by_lpf(a[0], lpf)) {
    int id = to[e];
    if (id < 200) c[0][id] += p;
    else se[id - 200].eb(0);
  }
  for (int t = 0; Z [w, x, y] : es) {
    ++t;
    vector fac = factor_by_lpf(w, lpf);
    int lca = v.lca(x, y), ff = fa[lca];
    for (Z &[e, p] : fac) {
      int id = to[e];
      if (id >= 200) {
        id -= 200;
        for (Z [l, r] : v.dec(x, y, 0)) {
          if (l > r) swap(l, r);
          Z it = se[id].lower_bound(l);
          if (it != se[id].ed() and (*it) <= r) {
            p -= 1;
            break;
          }
        }
        continue;
      }
      int d = c[x][id] + c[y][id] - c[lca][id] - (ff == -1 ? 0 : c[ff][id]);
      p -= d;
      chmax(p, 0);
    }
    c[t] = c[fa[t]];
    int val = 1;
    for (Z &[e, p] : fac) if (p) {
      FOR(p) val *= e;
      int id = to[e];
      if (id < 200) c[t][id] += p;
      else se[id - 200].eb(v.L[t]);
    }
    a[t] = val;
  }
  print(a);
}
```