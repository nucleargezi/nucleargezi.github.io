#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 3rd Universal Cup. Stage 32: Dhaka",
  desc: [ucup 3-32 训练记录],
  date: "2026-05-02",
  tags: ("icpc",),
  category: "ICPC",
)

= The 3rd Universal Cup. Stage 32: Dhaka

#link("https://qoj.ac/contest/1924", "Qoj Link")

== Hitokoto

假期组队训练

== A. Sort and &
- In-Contest Solves: 82/203 (ucup)
- #link("https://qoj.ac/contest/1939/problem/10214")

=== Formal Problem Statement

给定 $T$ 组测试数据. 每组给定一个长度为 $N$ 的排列 $a_1,a_2,dots,a_N$.

你需要通过若干次交换操作将排列排序, 即使得最终 $a_i = i$ 对所有 $1 <= i <= N$ 成立.

一次操作可以选择两个下标 $i,j$, 交换 $a_i$ 与 $a_j$, 本次操作的代价为下标 $i$ 与 $j$ 的按位与, 即 `i & j`.

要求在操作次数不超过 $3N$ 的前提下, 使总代价最小.

对于每组测试数据, 请输出最小总代价, 并输出任意一组达到该最小代价的交换方案.

=== Constraints

- $1 <= T <= 10^4$
- $1 <= N <= 10^4$
- $1 <= a_i <= N$
- $a_1,a_2,dots,a_N$ 是一个排列.
- $sum N <= 10^5$

=== Solution

对于当前位于位置 $i$ 的元素, 设它的目标位置为 $k$. 交换位置的代价为 $i amp k$, 因此当 $i amp k = 0$ 时, 这次交换可以视为零代价交换

分类讨论如何在最小代价下完成位置 $i$ 与位置 $k$ 的交换

+ 若 $i amp k = 0$, 则可以直接交换 $(i, k)$, 代价为 $0$.

+ 若 $i amp k != 0$, 考虑借助若干个 $2$ 的幂作为跳板

  - 若存在 $p = 2^j$, 满足
    $
      i amp p = 0 quad "and" quad k amp p = 0
    $
    则可以用 $p$ 作为一个跳板, 通过
    $
      (i, p), (p, k), (i, p)
    $
    完成交换, 总代价为 $0$

  - 否则, 若可以找到两个不同的跳板 $p, q$, 使得
    $
      i amp p = 0, quad p amp q = 0, quad q amp k = 0
    $
    则沿路径
    $
      i -> p -> q -> k
    $
    进行交换, 也可以零代价完成.

  - 若以上方法都不可行, 则这次交换不可避免地产生正代价
    由于任意正代价至少为 $1$, 因此尝试借助位置 $1$ 完成交换可达到最小代价

由于构造中需要用到 $2$ 的幂位置作为跳板, 可以先跳过这些位置, 最后再统一处理它们. 这个过程不会产生额外代价

=== Implementation
```cpp
void yorisou() {
  INT(N);
  vc<int> a(N + 1), f(a);
  FOR(i, 1, N + 1) IN(a[i]), f[a[i]] = i;

  ll s = 0;
  vc<PII> ans;
  Z op = [&](int i, int k) {
    if (i == k) return;
    s += i & k;
    swap(a[i], a[k]);
    f[a[i]] = i;
    f[a[k]] = k;
    ans.ep(i, k);
  };
  FOR_R(i, 2, N + 1) if (a[i] != i and (i != (1 << topbit(i)))) {
    int p = f[i];
    bool ok = 0;
    FOR(t, 20) {
      int c = 1 << t;
      if (c <= N and not(c & i) and not(c & p)) {
        op(c, p);
        op(i, c);
        ok = 1;
        break;
      }
    }
    if (not ok) {
      if (i == N and (i + 1) == (1 << topbit(i + 1))) {
        FOR(t, 1, 16) {
          if (not(p >> t & 1) and (1 << t) <= N) {
            ok = 1;
            op(p, 1 << t);
            op(1 << t, 1);
            op(1, i);
            break;
          }
        }
        if (not ok) op(p, 1), op(1, i);
      } else {
        FOR(j, 16) FOR(k, 16) if ((1 << max(j, k)) <= N and j != k and not ok) {
          if (not(p & (1 << j)) and not((1 << k) & i)) {
            op(p, (1 << j));
            op((1 << j), (1 << k));
            op((1 << k), i);
            ok = 1;
          }
        }
      }
    }
  }

  FOR_R(i, 20) if ((1 << i) <= N and a[1 << i] != (1 << i)) {
    op(1 << i, f[1 << i]);
  }

  print(s);
  print(si(ans));
  for (var t : ans) print(t);
}
```

== H. Are the nodes reachable?
- In-Contest Solves: 25/128 (ucup)
- #link("https://qoj.ac/contest/1939/problem/10221")

=== Formal Problem Statement

给定一个包含 $N$ 个点和 $M$ 条有向边的有向无环图, 点编号为 $1, 2, ..., N$.

有 $Q$ 次询问, 每次给定两个点 $U, V$. 你需要回答:

- 若在原图中 $V$ 可以从 $U$ 到达, 则答案为 $0$.
- 否则, 你可以临时添加一条从任意点 $X$ 到任意点 $Y$ 的有向边, 使得添加后 $V$ 可以从 $U$ 到达. 添加这条边的代价为 $|X - Y|$.

每次询问相互独立, 临时添加的边会在该次询问结束后删除.

对于每次询问, 输出使 $V$ 从 $U$ 可达所需的最小代价.

=== Constraints

- $sum N <= 10^5$
- $sum M <= 10^5$
- $sum Q <= 10^6$

=== Solution

先进行一次拓扑排序, 用 bitset 处理出每个点的可达情况

然后在两个 bitset 中暴力寻找距离最近的两个点

显然 $(N Q)/w$ 的复杂度是足以通过的, 尝试对暴力进行优化, 看看能不能弄到接近这个复杂度, 如果两个 bitset 中的 1 数量都超过了一半, 答案一定是 0 或者 1, 这部分特判掉, 剩下的至少有一个比较稀疏, 接下来尝试在两个 bitset 上双指针, 这部分内精细实现一下, 能得到常数比较小的暴力

=== Implementation
```cpp
bool any(const bs &a, const bs &b) {
  int N = si(a.a);
  FOR(i, N) if (a.a[i] & b.a[i]) return 1;
  return 0;
}

bool any1(const bs &a, const bs &b) {
  int N = si(a.a);
  FOR(i, N) {
    ull x = a.a[i], o = (x << 1) | (x >> 1);
    if (i) o |= a.a[i - 1] >> 63;
    if (i + 1 < N) o |= (a.a[i + 1] & 1ull) << 63;
    if (o & b.a[i]) return 1;
  }
  return 0;
}

inline int lz(ull x) { return __builtin_ctzll(x); }

inline int dis(ull x, ull y, int rs) {
  if (not x or not y) return rs;
  if (x & y) return 0;
  if (pc(x) > pc(y)) swap(x, y);
  for (; x; x &= x - 1) {
    int p = lz(x);
    if (p) {
      ull l = y & ((1ull << p) - 1);
      if (l) chmin(rs, p - topbit(l));
    }
    if (p != 63) {
      ull R = y >> (p + 1);
      if (R) chmin(rs, lz(R) + 1);
    }
    if (rs <= 1) break;
  }
  return rs;
}

int sol(const bs &a, const vc<u16> &lp, const bs &b, const vc<u16> &rp, int s) {
  int i, k = 0, j = 0, la = -inf<int>, lb = la;
  while (k < si(lp) or j < si(rp)) {
    if (j == si(rp)) i = lp[k];
    else if (k == si(lp)) i = rp[j];
    else i = min(lp[k], rp[j]);
    int bs = i << 6;
    ull x = 0, y = 0;
    if (k < si(lp) and lp[k] == i) x = a.a[i], ++k;
    if (j < si(rp) and rp[j] == i) y = b.a[i], ++j;
    if (x and lb != -inf<int>) chmin(s, bs + lz(x) - lb);
    if (y and la != -inf<int>) chmin(s, bs + lz(y) - la);
    if (x and y) s = dis(x, y, s);
    if (s <= 1) return s;
    if (x) la = bs + topbit(x);
    if (y) lb = bs + topbit(y);
  }
  return s;
}

void Yorisou() {
  INT(N, M);
  vc<vc<int>> g(N), rg(N);
  vector to(N, bs(N)), fr(to);
  vc<int> in(N), ou(N);
  FOR(M) {
    INT(f, t);
    --f, --t;
    g[f].ep(t);
    ++ou[t];
    rg[t].ep(f);
    ++in[f];
  }

  queue<int> q;
  FOR(i, N) if (in[i] == 0) q.eb(i);
  FOR(i, N) to[i].set(i);
  while (not q.empty()) {
    int n = pop(q);
    for (int x : rg[n]) {
      to[x] |= to[n];
      if (--in[x] == 0) q.eb(x);
    }
  }
  q.clear();
  FOR(i, N) if (ou[i] == 0) q.eb(i);
  FOR(i, N) fr[i].set(i);
  while (not q.empty()) {
    int n = pop(q);
    for (int x : g[n]) {
      fr[x] |= fr[n];
      if (--ou[x] == 0) q.eb(x);
    }
  }

  vc<u16> c(N), d(N);
  vc<vc<u16>> lp(N), rp(N);

  FOR(i, N) {
    const bs &v = to[i];
    int n = si(v.a);
    c[i] = v.count();
    FOR(k, n) if (v.a[k]) lp[i].ep(k);
  }
  FOR(i, N) {
    const bs &v = fr[i];
    int n = si(v.a);
    d[i] = v.count();
    FOR(k, n) if (v.a[k]) rp[i].ep(k);
  }

  INT(Q);
  FOR(Q) {
    INT(f, t);
    --f, --t;
    if (2 * c[f] >= N and 2 * d[t] >= N) {
      print(not any(to[f], fr[t]));
    } else {
      int s = abs(f - t);
      if (any(to[f], fr[t])) s = 0;
      else if (any1(to[f], fr[t])) s = 1;
      else {
        if (c[f] < d[t]) {
          chmin(s, sol(to[f], lp[f], fr[t], rp[t], s));
        } else {
          chmin(s, sol(fr[t], rp[t], to[f], lp[f], s));
        }
      }
      print(s);
    }
  }
}
```

== L. Uncle Bob and XOR Sum
- In-Contest Solves: 72/203 (ucup)
- #link("https://qoj.ac/contest/1939/problem/10225")

=== Formal Problem Statement

给定 $T$ 组测试数据. 每组数据给定一个长度为 $N$ 的整数数组 $A$ 和一个长度为 $K$ 的整数数组 $B$.

对于一个非空位置子集 $P subset.eq {1, 2, ..., N}$, 定义其异或和为
$ S = xor_(i in P) A_i $.

称整数 $m$ 是整数 $S$ 的子掩码, 当且仅当 $m$ 的所有为 $1$ 的二进制位在 $S$ 中也为 $1$, 即 $(m and S) = m$.

需要计算有多少个非空位置子集 $P$, 满足其异或和 $S$ 的任意子掩码都不在数组 $B$ 中出现. 等价地, 对所有 $1 <= j <= K$, 都有 $B_j$ 不是 $S$ 的子掩码, 即 $(B_j and S) != B_j$.

输出答案对 $1000000007$ 取模后的结果.

=== Constraints

- $1 <= T <= 100$
- $1 <= N <= 10^5$
- $1 <= K <= 10$
- $0 <= A_i <= 2^31 - 1$
- $0 <= B_i <= 2^31 - 1$
- $sum N <= 10^5$

=== Solution

一类被出了很多次, 比较典型的线性基题

对于一个集合 T , 计算集合 S 中能表示出 T 的子集数量, 可以取出 $sp(T)$ 中的有效位, 去掉 S 中元素的无效位, 如果这时 $sp(S)$ 能表示出所有这些有效位, 那么答案就是 $2^(|S| - |sp(T)|)$

在这题中, 对 T 的每个子集计算一次进行容斥可以得到答案

=== Implementation
```cpp
using mint = M11;
using bs = sp<uint>;
void yorisou() {
  INT(N, K);
  VEC(uint, a, N);
  VEC(uint, b, K);
  for (uint x : b) if (x == 0) return print(0);
  bs sa;
  for (uint x : a) sa.add(x);
  mint s = mint(2).pow(N) - 1;
  FOR(m, 1 << K) {
    int msk = 0;
    FOR(i, K) if (m >> i & 1) msk |= b[i];
    bs sb;
    for (uint x : sa.a) sb.add(x & msk);
    if (not sb.contain(msk)) continue;
    mint t = mint(2).pow(N - si(sb));
    if (pc(m) & 1) s -= t;
    else s += t;
  }
  print(s);
}
```

== M. Tree Flip
- In-Contest Solves: 25/102 (ucup)
- #link("https://qoj.ac/contest/1939/problem/10226")

=== Formal Problem Statement

给定 $T$ 组测试数据. 每组数据给定一棵包含 $N$ 个点的无根树, 每个点 $i$ 有一个二进制权值 $A_i in {0, 1}$, 初始时以 $1$ 为根

对于当前根确定的有根树, Alu 可以进行若干次操作. 每次操作选择一个点 $u$, 将点 $u$ 以及 $u$ 的所有儿子的权值翻转, 即 $0$ 变为 $1$, $1$ 变为 $0$. 注意只翻转直接儿子, 不翻转更深的后代

接下来有 $Q$ 次更新, 每次更新属于以下两种之一:

- `1 x`: 将点 $x$ 的权值翻转
- `2 x`: 将整棵树的根改为点 $x$

每次更新后, 需要在当前根和当前点权下, 输出 Alu 至少需要多少次操作才能将所有点的权值全部变为 $0$

Alu 的操作只作用在 Begun 的树的一份副本上, 不会改变后续更新中的树和点权

=== Constraints

- $1 <= T <= 10^4$
- $1 <= N$
- $1 <= Q$
- $1 <= x <= N$
- $"type" in {1, 2}$
- $A_i in {0, 1}$
- $sum N <= 10^5$
- $sum Q <= 10^5$

=== Solution

怎么真有动态换根 dp 的题, 没有人类了

本质上是要统计从根出发有多少条 $sum xor$ 为 1 的路径, 如果没有修改的话直接 dp 就行, 带修改可以 Static-Toptree, 最好写的做法可能是 LCT 维护动态 dp

=== Implementation
```cpp
struct DP {
  struct X {
    int op;
    bool top[2], dn[2];
    int s[2], com[2];
  };

  static X sing(int f) {
    X x {};
    x.op = 0;
    FOR(i, 2) x.top[i] = x.dn[i] = x.s[i] = i ^ f;
    return x;
  }

  static X com(const X &L, const X &R) {
    X c{};
    c.op = 0;
    FOR(i, 2) {
      int cld = L.dn[i], cru = R.top[cld];
      c.top[i] = L.top[i];
      c.dn[i] = R.dn[cld];
      c.s[i] = L.s[i] + R.s[cld] + L.com[cru];
      c.com[i] = R.com[i];
    }
    return c;
  }

  static X com1(const X &L, const X &R) { return com(L, R); }

  static X com2(const X &L, const X &R) {
    X x = L;
    x.com[0] += R.s[0];
    x.com[1] += R.s[1];
    return x;
  }

  static X rak(const X &L, const X &R) {
    X x = L;
    x.s[0] += R.s[0];
    x.s[1] += R.s[1];
    return x;
  }

  static X rak1(const X &L, const X &R) {
    X x = L;
    FOR(p, 2) x.s[p] += R.s[L.top[p]];
    return x;
  }
};
using X = DP::X;
void Yorisou() {
  INT(N, Q);
  VEC(char, a, N);
  FOR(i, N) a[i] -= '0';
  graph g(N);
  g.sc();
  hld v(g);
  Z make = [&](int i) -> pair<X, X> {
    X x = DP::sing(a[i]);
    return {x, x};
  };
  dynamic_tree_dp_re<int, DP> dp(v, make);
  int t = 0;
  FOR(Q) {
    INT(op, i);
    --i;
    if (op == 1) a[i] ^= 1, dp.set(i, make(i));
    if (op == 2) t = i;
    print(dp.prod(t).s[0]);
  }
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
