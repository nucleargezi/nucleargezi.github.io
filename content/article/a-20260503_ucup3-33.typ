#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 3rd Universal Cup. Stage 33: India",
  desc: [ucup 3-33 训练记录],
  date: "2026-05-03",
  tags: ("icpc",),
  category: "ICPC",
)

= The 3rd Universal Cup. Stage 33: India

#link("https://qoj.ac/contest/1954", "Qoj Link")

== Hitokoto

假期组队训练

== C. Construct uwu
- In-Contest Solves: 22/40 (ucup)
- #link("https://qoj.ac/contest/1954/problem/10267")
=== Formal Problem Statement

给定 $T$ 组测试数据, 每组给定一个正整数 $N$

你需要构造一个只由字符 `"u"` 和 `"w"` 组成的字符串 $S$, 使得 $S$ 中等于 `"uwu"` 的子序列个数恰好为 $N$

在所有满足条件的字符串中, 输出长度最小的任意一个

这里子序列不要求连续, 只要求保留字符的相对顺序

保证每组测试数据至少存在一个合法答案

=== Constraints

- $1 <= T <= 10^3$
- $1 <= N <= 10^18$
- $sum |"ans"| < 10^7$
=== Solution

要让 "uwu" 最多, 一定是分成三段 "u...", "w...", "u..." , 记它们的数量为 $a, b, c$, 总数为 $a * b * c$ , 在三段尽量均分的时候 "uwu" 最多, 这样就知道了一个固定长度的串的最大贡献, 可以以此二分出最终串的长度

而要让答案为 $N$ , 需要在最优的基础上进行调整

令 $a=b$, 尝试将中间的 'w' 向右移动, 此时移动造成的答案减少是移动距离的平方, 所以只需要贪心地将多出的部分拆成若干个完全平方数即可

当答案很小的时候可能不准, 可以打表打出比较小的答案, 大的用这种策略去构造

=== Implementation
```cpp
void Yorisou() {
  hashmap<string> mp(1000);
  ll a[18], b[18];
  FOR(sz, 1, 18) {
    FOR(s, 1 << sz) {
      FOR(i, sz) b[i] = a[i] = s >> i & 1;
      FOR(i, sz - 1) a[i + 1] += a[i];
      FOR_R(i, sz - 1) b[i] += b[i + 1];
      ll v = 0;
      FOR(i, 1, sz - 1) if (~s >> i & 1) v += a[i - 1] * b[i + 1];
      if (not mp.contains(v)) {
        string str;
        FOR(i, sz) str += (s >> i & 1) ? 'u' : 'w';
        mp[v] = str;
      }
    }
  }
  INT(N);
  FOR(N) {
    LL(x);
    if (mp.contains(x)) {
      print(mp[x]);
    } else {
      ll t = bina([&](ll t) -> bool {
        ll a = t / 3, b = (t - a) /  2, c = t - a - b;
        return a * b * c >= x;
      }, 6'000'010, 0);
      ll a = t / 3, b = (t - a) / 2, c = t - a - b;
      if (a == b) swap(b, c);
      else if (b == c) swap(a, b);
      ll ex = a * b * c - x;
      vc<PLL> ls;
      while (ex) {
        ll g = bina([&](ll t) -> bool { return t * t <= ex; }, 0, c + 1);
        ll d = ex / (g * g);
        b -= d;
        ex -= d * g * g;
        ls.ep(d, g);
      }
      string s;
      FOR(a) s += 'u';
      FOR(b) s += 'w';
      FOR(i, c) {
        if (si(ls) and ls.back().se == i) {
          int n = pop(ls).fi;
          FOR(n) s += 'w';
        }
        s += 'u';
      }
      for (var [n, d] : ls) FOR(n) s += 'w';
      print(s);
    }
  }
}
```

== H. Majority Graph
- In-Contest Solves: 31/88 (ucup)
- #link("https://qoj.ac/contest/1954/problem/10272")
=== Formal Problem Statement

给定 $T$ 组测试数据, 每组给定一个长度为 $N$ 的数组 $A_1, A_2, dots, A_N$

构造一个有 $N$ 个点的无向图 $G$, 点的编号为 $1$ 到 $N$

对于每一对满足 $1 <= i < j <= N$ 的点 $(i, j)$, 若子数组 $A_i, A_{i + 1}, dots, A_j$ 存在一个众数, 则在 $i$ 和 $j$ 之间连一条边

一个长度为 $M$ 的数组存在众数, 当且仅当存在某个值 $X$, 其出现次数严格大于 $M / 2$

对于每组测试数据, 求图 $G$ 的连通块个数

=== Constraints

- $1 <= T <= 10^5$
- $2 <= N <= 2 dot 10^6$
- $1 <= A_i <= N$
- $sum N <= 2 dot 10^6$

=== Solution

考虑一下暴力怎么做, 找出某个数字出现的所有位置, 将这些位赋为 1 , 其他位赋为 -1 , 利用前缀和找出这个数字作为绝对众数的所有区间进行合并, 实现上可以每次合并后贪心地保留靠后的, 这种做法对于每个数字需要 On 的处理

但实际上对于每个数字可以利用密度来找出包含所有区间众数区间的最小区间划分, 这个东西的总长度最多是 $2 * N$ , 对着所有这样的区间暴力处理一遍即可

用同样的方法, 其实也可以不重不漏地对存在绝对众数的区间进行统计

=== Implementation
```cpp
void yorisou() {
  INT(N);
  VEC(int, a, N);
  vc<vc<int>> g(N);
  FOR(i, N) g[--a[i]].ep(i);

  fset se(N << 1 | 1);
  vc<vc<int>> v(N << 1 | 1);
  dsu un(N);
  Z ke = [&](int l, int r, int t) -> void {
    chmax(l, 0), chmin(r, N);
    int of = N;
    FOR(i, l, r) {
      v[of].ep(i), se.emplace(of);
      if (a[i] == t) ++of;
      else --of;
      int nx = -1;
      while (1) {
        int k = se.prev(of - 1);
        if (k >= 0) {
          for (var x : v[k]) un.merge(x, i);
          v[k].clear();
          se.erase(k);
          nx = k;
        } else break;
      }
      if (nx != -1) v[nx].ep(i), se.eb(nx);
    }
    for (int x : se.get_all()) se.erase(x), v[x].clear();
  };
  FOR(t, N) if (si(g[t]) > 1) {
    for (var [l, r] : enum_density_range(2, g[t])) {
      ke(l, r, t);
    }
  }
  print(un.c);
}
```

== J. Max Mod
- In-Contest Solves: 45/171 (ucup)
- #link("https://qoj.ac/contest/1954/problem/10274")
=== Formal Problem Statement

给定整数 $N, M, Q$, 其中 $M$ 为质数

有一个长度为 $N$ 的数组 $A$, 初始时所有 $A_i = 0$

需要依次处理 $Q$ 次操作, 操作分为两类

- 给定 $X, Y$, 对所有 $1 <= i <= N$, 将 $A_i$ 加上 $X + (i - 1) dot Y$
- 给定 $L, R$, 求 $max_(L <= i <= R) (A_i mod M)$

对于每个询问操作, 输出对应答案

=== Constraints

- $1 <= N, Q <= 5 dot 10^5$
- $1 <= M <= 10^9$
- $M$ is prime
- $T in {1, 2}$
- $1 <= X, Y <= 10^9$
- $1 <= L <= R <= N$

=== Solution

这题是何意味啊, 出一个板子题

原题链接: #link("https://judge.yosupo.jp/problem/min_of_mod_of_linear", "Min of Mod of Linear (yosupo)")

=== Implementation
```cpp
void yorisou() {
  INT(N, P, Q);
  ll a = 0, b = 0;
  FOR(Q) {
    INT(op);
    if (op == 1) {
      INT(x, y);
      a = (a + P - y) % P;
      b = (b + P - x) % P;
    } else {
      INT(l, r);
      --l;
      print(max_line(l, r, a, b, P).se);
    }
  }
}
```

== N. Yet Another MST Problem
- In-Contest Solves: 91/152 (ucup)
- #link("https://qoj.ac/contest/1954/problem/10278")
=== Formal Problem Statement

给定 $T$ 组测试数据, 每组给定一个有 $N$ 个点和 $M$ 条边的连通无向图 $G$, 每条边的权值均为 $1$

给定一个长度为 $N$ 的 01 字符串 $S$, 若 $S_i = 1$, 则点 $i$ 被标记, 否则点 $i$ 未被标记

设所有被标记的点构成集合 $X$, 保证 $X$ 非空

在点集 $X$ 上构造一个完全图 $H$, 对于任意两个不同的标记点 $u, v$, 它们之间边的权值为 $"dist"(u, v)$, 其中 $"dist"(u, v)$ 表示在原图 $G$ 中从 $u$ 到 $v$ 的最短路长度

对于每组测试数据, 求完全图 $H$ 的最小生成树边权和

=== Constraints

- $1 <= T <= 10^4$
- $2 <= N <= 2 dot 10^5$
- $N - 1 <= M <= 2 dot 10^5$
- $S_i in {0, 1}$
- $|S| = N$
- 存在至少一个 $i$ 满足 $S_i = 1$
- $1 <= u, v <= N$
- $u != v$
- $sum N, M <= 2 dot 10^5$

=== Solution

构思题, bfs , 过程中扩展每个连通块并计算贡献

=== Implementation
```cpp
void yorisou() {
  INT(N, M);
  STR(s);
  FOR(i, N) s[i] -= '0';
  vc<vc<int>> g(N);
  FOR(M) {
    INT(f, t);
    --f, --t;
    g[f].ep(t);
    g[t].ep(f);
  }
  
  dsu f(N);
  vc<PII> q;
  vc<int> dis(N, N + 1);
  vc<char> vis(N);
  FOR(i, N) if (s[i]) dis[i] = 0, q.ep(i, 0), vis[i] = 1;
  ll al = 0;
  while (si(q)) {
    vc<PII> qq(q), me;
    while (si(qq)) {
      int n = pop(qq).fi;
      for (int x : g[n]) {
        if (f[x] == f[n]) continue;
        if (vis[x]) me.ep(n, x);
      }
    }
    sort(all(me), [&](PII a, PII b) {
      return dis[a.fi] + dis[a.se] < dis[b.fi] + dis[b.se];
    });
    for (var [x, y] : me) if (f.merge(x, y)) al += dis[x] + dis[y] + 1;
    while (si(q)) {
      Z [n, d] = pop(q);
      for (int x : g[n]) {
        if (f[x] != f[n] and not vis[x]) {
          if (chmin(dis[x], d + 1)) {
            qq.ep(x, d + 1);
            vis[x] = 1;
            f.merge(x, n);
          }
        }
      }
    }
    q.clear();
    for (var [n, d] : qq) if (d == dis[n]) q.ep(n, d);
  }
  print(al);
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
