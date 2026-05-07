#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 3rd Universal Cup. Stage 39: Tokyo",
  desc: [ucup 3-39 训练记录],
  date: "2026-05-05",
  tags: ("icpc",),
  category: "ICPC",
)

= The 3rd Universal Cup. Stage 39: Tokyo

#link("https://qoj.ac/contest/2071", "Qoj Link")

== Hitokoto

假期组队训练

== B. Bracket Character Frequency
- In-Contest Solves: 137/352 (ucup)
- #link("https://qoj.ac/contest/2071/problem/10971")
=== Formal Problem Statement

给定 $T$ 组测试数据, 每组给定整数 $N, K$ 和一个长度为 $2K$ 的整数序列 $A_1, A_2, dots, A_(2K)$

称一个只由字符 `"("` 和 `")"` 组成的字符串为正确括号序列, 当且仅当它可以由空串, 外层匹配括号包裹一个正确括号序列, 或两个非空正确括号序列拼接得到

需要判断是否存在一个由 $N$ 个正确括号序列组成的元组, 使得每个正确括号序列的长度均为 $2K$, 且对于每个位置 $i$, 在这 $N$ 个序列中恰好有 $A_i$ 个序列的第 $i$ 个字符为 `"("`

对于每组测试数据, 若存在满足条件的元组, 输出 `Yes`, 否则输出 `No`

=== Constraints

- $1 <= T <= 10^5$
- $1 <= N <= 10^12$
- $1 <= K <= 2 dot 10^5$
- $0 <= A_i <= N$
- $sum K <= 5 dot 10^5$

=== Solution

直接模拟, 每次贪心把新增的 '(' 给前缀 '(' 少的串

=== Implementation
```cpp
void yorisou() {
  INT(N, K);
  map<int, ll> q;
  q[0] = N;
  vc<PLL> st;
  VEC(ll, a, K << 1);
  FOR(i, 2 * K) {
    ll x = a[i];
    st.clear();
    while (x) {
      Z it = bg(q);
      Z [c, n] = *it;
      q.erase(it);
      ll d = min(x, n);
      x -= d;
      n -= d;
      st.ep(c + 1, d);
      if (n) st.ep(c, n);
    }
    for (var [c, n] : st) q[c] += n;
    if (q.bg()->fi * 2 < i + 1) return print("No");
  }
  ll s = 0;
  for (var [a, b] : q) if (a == K) s += b;
  print(s == N ? "Yes" : "No");
}
```

== G. Guarding Plan
- In-Contest Solves: 53/170 (ucup)
- #link("https://qoj.ac/contest/2071/problem/10976")

=== Formal Problem Statement

给定平面上的 $N$ 个守卫, 第 $i$ 个守卫位于点 $(x_i, y_i)$

你可以执行任意次操作, 每次操作选择两个当前已有守卫所在的点, 再选择这两个点连线段上的任意一点, 若该点还没有守卫, 则在该点放置一个新的守卫

一个位于 $(a, b)$ 的守卫可以监视所有满足 $x <= a$ 且 $y <= b$ 的守卫

若一个守卫没有被任何其他守卫监视, 则称其为必要守卫

你需要求最终局面中必要守卫数量的最小可能值, 并在达到该最小值的前提下, 求所需操作次数的最小值

=== Constraints

- $1 <= N <= 2 dot 10^5$
- $0 <= x_i, y_i <= 10^9$
- $(x_i, y_i) != (x_j, y_j)$ 对于 $i != j$

=== Solution

先从后往前扫一遍将已经被覆盖的点去掉, 对于剩下的点, 处于非严格凸包上的点一定是不能删的, 新增的点一定在凸包的边上, 对于凸包上相邻两个点的 x 坐标范围内的其他点, 尝试新增点进行覆盖

对于凸包上的一条斜边 $(x, y) - (x + a, y - b)$ , 对于范围内的每个点, 可以知道想要覆盖它, 最远新增点的 x 在哪里, 也就是每个点存在一个覆盖范围, 如果以它为一个新增点的边界的话; 所以用一些数据结构优化一个区间取 min 的 dp 来处理每个区间就行

这里贪心也可以得到最小有效点数, 只需要贪心扩展每次新增点覆盖的右边界, 最后去掉只覆盖了一个点的无效覆盖就行, 但这样操作次数不一定是最优的, 还是必须以点数为第一关键字, 操作次数为第二关键字进行 dp 才行

=== Implementation
```cpp
using P = point<ll>;
using DS = seg_dual_t<Min<PII>>;
void yorisou() {
  INT(N);
  map<int, int> mp;
  FOR(N) {
    INT(x, y);
    chmax(mp[x], y);
  }
  vc<P> a;
  for (var [x, y] : mp) a.ep(x, y);
  N = si(a);
  int mx = -1;
  FOR_R(i, N) {
    var [x, y] = a[i];
    if (chmax(mx, y)) a.ep(x, y);
  }
  a.erase(bg(a), bg(a) + N);
  reverse(all(a));
  N = si(a);

  vc<char> vis(N);
  vc<int> s;
  FOR(i, N) {
    while (si(s) > 1) {
      int l = s.ed()[-2], m = s.ed()[-1];
      if (ccw(a[l], a[m], a[i]) == 1) pop(s);
      else break;
    }
    s.ep(i);
  }
  for (int x : s) vis[x] = 1;
  vc<int> L(N), R(N);
  FOR(i, N) {
    if (vis[i]) L[i] = i;
    else L[i] = L[i - 1];
  }
  FOR_R(i, N) {
    if (vis[i]) R[i] = i;
    else R[i] = R[i + 1];
  }

  vc<vc<PII>> rgs(N);
  FOR(i, N) if (not vis[i]) {
    int l = L[i], r = R[i];
    int d = bina([&](int d) -> bool {
      P tmp = a[i];
      tmp.x += d;
      return ccw(a[l], tmp, a[r]) != -1;
    }, 0, a[r].x - a[i].x);
    int rx = a[i].x + d;
    rgs[l].ep(i, bina([&](int p) { return rx >= a[p].x; }, i, N) + 1);
  }

  int co = SUM<int>(vis), op = 0;
  DS seg(N);
  FOR(i, N) if (si(rgs[i])) {
    Z &v = rgs[i];
    seg.apply(i, i + 1, {0, 0});
    for (var [ls, rs] : v) {
      Z [a, b] = seg.get(ls - 1);
      seg.apply(ls, ls + 1, {a + 1, b});
      seg.apply(ls, rs, {a + 1, b + 1});
    }
    var [a, b] = seg.get(R[i + 1] - 1);
    co += a, op += b;
  }
  print(co);
  print(op);
}
```

== Q. Quadratic Pieces
- In-Contest Solves: 145/245	 (ucup)
- #link("https://qoj.ac/contest/2071/problem/10986")

=== Formal Problem Statement

给定 $T$ 组测试数据, 每组给定一个长度为 $N$ 的整数序列 $A_1, A_2, dots, A_N$

对于一段连续子序列 $(A_L, A_(L + 1), dots, A_R)$, 若存在实数 $a, b, c$, 使得对于所有 $L <= i <= R$, 都有 $A_i = a i^2 + b i + c$, 则称这段子序列是二次的

你需要将整个序列划分为若干个连续的二次子序列

对于每组测试数据, 求最少需要划分成多少段

=== Constraints

- $1 <= T <= 10^5$
- $1 <= N <= 2 dot 10^5$
- $-10^18 <= A_i <= 10^18$
- $sum N <= 2 dot 10^5$

=== Solution

注意到每个序列的二阶差分是个常数, 以此划分即可

=== Implementation
```cpp
void yorisou() {
  INT(N);
  VEC(int, a, N);
  int s = 0;
  for (int l = 0, r; l < N; l = r) {
    r = l + 1;
    ll d;
    while (r < N) {
      if (r - 1 == l) {
        d = a[r] - a[l];
        ++r;
      } else if (r - 2 == l) {
        d = a[r] - a[r - 1] - d;
        ++r;
      } else {
        ll g = a[r] - a[r - 1] - (a[r - 1] - a[r - 2]);
        if (g != d) break;
        ++r;
      }
    }
    ++s;
  }
  print(s);
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
