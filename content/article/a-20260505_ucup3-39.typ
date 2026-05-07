#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 3rd Universal Cup. Stage 34: Aobayama",
  desc: [ucup 3-33 训练记录],
  date: "2026-05-02",
  tags: ("icpc",),
  category: "ICPC",
)

= The 3rd Universal Cup. Stage 34: Aobayama

#link("https://qoj.ac/contest/1965", "Qoj Link")

== Hitokoto

假期组队训练

== N. Palindromic Path
- In-Contest Solves: 43/181 (ucup)
- #link("https://qoj.ac/contest/1965/problem/10334")
=== Formal Problem Statement

给定一个有 $2N$ 个点和 $M$ 条边的简单无向图 $G$

对于每个点 $i$, 它的标签为 $floor((i + 1) / 2)$, 因此点 $2x - 1$ 和点 $2x$ 的标签均为 $x$

称一个点序列 $P = (v_1, v_2, dots, v_K)$ 为回文路径, 当且仅当满足以下条件

- $K >= 2$
- $P$ 是一条简单路径, 即相邻点之间均有边, 且不重复经过同一个点
- 路径上点的标签序列构成回文, 即对于所有 $1 <= k <= floor(K / 2)$, 有 $floor((v_k + 1) / 2) = floor((v_(K - k + 1) + 1) / 2)$

对于每个 $x = 1, 2, dots, N$, 判断是否存在一条从某个标签为 $x$ 的点出发的回文路径

=== Constraints

- $1 <= N <= 2 dot 10^5$
- $1 <= M <= 4 dot 10^5$
- $1 <= u_j < v_j <= 2N$
- $(u_i, v_i) != (u_j, v_j)$ for $i != j$

=== Solution

要写的东西有点多, 但每一步都不难, 有点拼好题

回文路径去掉头尾还是回文路径, 这启发选手以这种方式建图: 若 $2i, 2i+1$ 可以分别到达 $2k, 2k+1$, 就连一条有向边 $i->k$, 当然此时也一定有一条边 $k->i$ 存在, 当无向边就行 , 这样对于任何一个合法起点, 从它出发产生的所有路径都是一个回文串, 也就是它能到达的点都可以作为合法回文路径的起点

现在可以枚举回文中心, 分两种情况:
+ 回文路径长度为偶, 回文中心是某个 $2i, 2i+1$ , 这种中心可以直接枚举, 它所在的连通块都可以贡献答案
+ 回文路径为奇, 这时存在一个问题, 实现上是枚举它能到达的合法点对作为中心向外扩展, 例如 "abcba", 统计过程是对于奇中心 'c', 枚举起点 'b', 这时真正作为中心的数字不能在其他地方使用, 也就是合法路径不能经过它, 需要进行一些处理

可以使用圆方树将图转化成一个森林, 然后处理出整个森林的 dfn ,维护一个 dfs 序的贡献序列 , 对于第一种情况就是对某个点所在的树进行一次区间加, 而在第二种情况中, 如果奇中心和起点在一个连通块内, 相当于要对圆方树内刨去奇中心以起点为根的子树, 剩下部分产生贡献, 相当于对整棵树产生 1 的贡献, 然后对这个子树部分扣掉 1 的贡献, 可以通过倍增 lca 来处理出这部分影响的 dfn 区间

最后对整个贡献序列做一次前缀和, 看一下哪些点存在贡献哪些不存在

=== Implementation
```cpp
void yorisou() {
  INT(N, M);
  vc<vc<int>> v(N << 1), g(N);
  FOR(M) {
    INT(a, b);
    --a, --b;
    v[a].ep(b), v[b].ep(a);
  }
  vc<int> c(N << 1), to;
  FOR(i, N) {
    to.clear();
    for (int x : v[i << 1]) c[x] |= 1;
    for (int x : v[i << 1 | 1]) c[x] |= 2;
    for (int x : v[i << 1]) {
      int a = x, b = x ^ 1;
      if (((c[a] & 1) and (c[b] & 2)) or 
          ((c[a] & 2) and (c[b] & 1))) {
        to.ep(x >> 1);
      }
    }
    for (int x : v[i << 1]) c[x] = 0;
    for (int x : v[i << 1 | 1]) c[x] = 0;
    unique(to);
    for (int x : to) if (i != x) g[i].ep(x);
  }

  vc<vc<int>> ng = bct(g);
  int cc = si(ng);
  doubling db(ng);
  var L = db.L;
  var R = db.R;

  dsu f(cc);
  FOR(i, cc) for (int x : ng[i]) f.merge(i, x);

  vc<PII> lr(cc, {cc + 1, -1});
  FOR(i, cc) {
    Z &[l, r] = lr[f[i]];
    chmin(l, L[i]), chmax(r, R[i]);
  }
  
  vc<int> pr(cc + 1);
  Z op = [&](PII lr, bool f) -> void {
    var [l, r] = lr;
    if (f) ++pr[l], --pr[r];
    else --pr[l], ++pr[r];
  };
  Z apply = [&](int x, int rt, bool a = 1) -> void {
    if (x == rt) return op(lr[f[x]], a);
    if (not db.ins(rt, x)) return op({L[x], R[x]}, a);
    x = db.jump(x, rt, 1);
    int l = L[x], r = R[x];
    var [LL, RR] = lr[f[x]];
    op({LL, l}, a);
    op({r, RR}, a);
  };

  FOR(i, N) for (int x : v[i << 1]) {
    if (x == (i << 1 | 1)) apply(i, i, 1);
  }
  vc<int> q;
  FOR(i, N << 1) {
    q.clear();
    for (int x : v[i]) q.ep(x >> 1);
    sort(all(q));
    int sz = si(q);
    FOR(k, sz - 1) if (q[k] == q[k + 1]) {
      int x = q[k];
      apply(x, x, 1);
      if (f[i >> 1] == f[x]) apply(i >> 1, x, 0);
    }
  }
  FOR(i, cc) pr[i + 1] += pr[i];
  FOR(i, N) print(pr[L[i]] > 0 ? "Yes" : "No");
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
