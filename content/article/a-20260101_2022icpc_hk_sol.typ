#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "2022 ICPC Hongkong Training REC",
  desc: [2022 ICPC HK 训练记录],
  date: "2026-01-01",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.sol,
    blog-tags.rec,
  ),
  show-outline: true,
)

#set text(size: 8pt)

#let msk = "■";
#let HL(s) = text(size: 9pt)[*#s*]
#let tab = text[#h(8pt)]
#let endl = linebreak()

= The 47th ICPC Asia Hong Kong Regional Contest

== 鲜花

最后一场区域赛打完很长一段时间没有进行组队训练，我也没有进行 5h 场的个人 vp ，总之就是没怎么训这方面，有些不太适应，变得有些杂鱼

今天 vp 打了 3h 才发现这场上赛季和队友 vp 过，当时 C 和 F 两个题就做好久，今天还是做了好久，C 甚至赛时没做出来，不过过了个前年没过的神秘题，单人打了 7 题，也还行吧。其他题没什么印象，该不会我当时看都没看就被队友做了（什

== A

简单 dp 题

父节点只能在子节点全部生成完才能释放，所以以从小到大的顺序释放子节点，最后一个子节点直接用父节点的寄存器生成，这颗子树需要的代价就是最大子节点代价和第二大 +1 取 max ，没有子节点就是 1 ，dp 一下得到答案

#zebraw(
```cpp
void Yorisou() {
  INT(N);
  vc<vc<int>> v(N);
  FOR(i, N) {
    INT(f);
    --f;
    if (f != -1) v[f].ep(i);
  }
  Z f = [&](Z &f, int n) -> int {
    max_heap<int> q;
    for (int x : v[n]) q.eb(f(f, x));
    if (q.empty()) return 1;
    int s = pop(q);
    if (not q.empty()) chmax(s, pop(q) + 1);
    return s;
  };
  print(f(f, 0));
}
```
)

#pagebreak()

== B

神秘题，感觉挺简单的，不知道为什么过的不多，可能有点脑电波或者歪榜了

左上半圈是黑的，右下半圈是白的，这两个连通块固定存在，并且黑连通块一定只有一个。其他的白连通块由黑色条带分割而成，现在目标就是寻找一个方法来*不重不漏*地统计白色连通块的期望

寻找白色连通块的特征用于统计，由于染色是向右或者向下的条带，每个都会有一个特征，它的*右下角*一定是最突出的角之一，整个连通块右下半圈被黑色包裹，所以可以统计 以某个方格为右下角的白色连通块 的期望，每个白色方格的期望就是右边和下面被黑色覆盖的期望乘上本身没被覆盖的期望

#zebraw(
```cpp
using mint = M99;
void Yorisou() {
  INT(N, M);
  retsu<mint> a(N + 1, M + 1), b(a);
  FOR(i, N) FOR(k, M) IN(a[i][k]);
  FOR(i, N) FOR(k, M) IN(b[i][k]);
  FOR(i, N) FOR_R(k, M) a[i][k] += a[i][k + 1];
  FOR(k, M) FOR_R(i, N) b[i][k] += b[i + 1][k];
  mint s = 2;
  FOR(i, N) FOR(k, M) {
    s += a[i + 1][k] * b[i][k + 1] * (mint(1) - a[i][k]) * (mint(1) - b[i][k]);
  }
  print(s);
}
```
)

#pagebreak()

== C

有点麻烦的构造

首先 $N * M$ 要是偶数

令小的为 N 大的为 M ，1 << N 不能小于 M ，否则枚举所有的 msk 都不够用

有个很简单的想法，前 M / 2 列按顺序放 msk ，后 M / 2 列 *bit rev* 着放（中间要是多一列就塞个 01 交题的，此时 N 肯定是偶数，如果重了就继续枚举 msk 换掉重的那一对），这样一定各列不同，01 个数相等

然后就会发现这样做有问题，会出现一些重复行

现在想个办法规避重复行，并且*不能破坏*原来这个 msk + 翻转的优秀构造

可以考虑一批特殊的二进制构造，选择 log 列，进行这种构造：
#zebraw(
```bash
0 0 0
1 0 0
0 1 0
1 1 0
0 0 1
1 0 1
0 1 1
1 1 1
```
)
除了 01010101 这种列，其他的还是对称翻转处理，这样就解决了行的问题，于是做完了

#zebraw(
```cpp
void Yorisou() {
  INT(N, M);
  if ((N * M) & 1) return NO();
  bool o = 0;
  if (N > M) swap(N, M), o = 1;

  using bs = bitset<1000>;
  vc<bs> a(N);
  vc<char> now{1};
  int c = 0;
  Z f = [&](Z &f, int p) -> void {
    if (c == (M + 1) >> 1) return;
    if (p >= N) {
      ++c;
      FOR(i, N) a[i][c - 1] = now[i];
      return;
    }
    now.ep(0);
    f(f, p + 1);
    now.back() = 1;
    f(f, p + 1);
    now.pop_back();
  };
  f(f, 1);

  int lm = (M + 1) >> 1;
  if (c != lm) return NO();
  
  Z same = [&](int i) -> bool {
    FOR(k, N) if (a[k][i] != now[k]) return 0;
    return 1;
  };
  Z fil = [&](int i) -> void {
    FOR(k, N) a[k][i] = now[k];
  };
  Z cp = [&](int i, int k) -> void {
    FOR(j, N) a[j][i] = not a[j][k];
  };

  now.resize(N);
  set<int> se;
  int jj = -1;
  for (int l = 1; l < N; l <<= 1) {
    FOR(j, N) now[j] = not((j / l) & 1);
    int gg = -1;
    FOR(i, lm) if (same(i)) {
      gg = i;
      break;
    }
    if (gg == -1) {
      FOR(i, lm) if (not se.contains(i)) {
        gg = i;
        break;
      }
      fil(gg);
    }
    se.eb(gg);
    if (l == 1) jj = gg;
  }

  if (M & 1) {
    int tt = lm;
    FOR(i, lm) if (i != jj) cp(tt++, i);
  } else {
    FOR(i, lm) cp(lm + i, i);
  }
  YES();
  if (o) {
    vc<bs> t(M);
    FOR(i, N) FOR(k, M) t[k][i] = a[i][k];
    a.swap(t);
    swap(N, M);
  }
  FOR(i, N) {
    FOR(k, M) cout << a[i][k];
    print();
  }
}
```
)

#pagebreak()

== D

有趣凸包题

以黑边数量为 x 坐标，黑边数量对应的最小白边数量为 y 坐标，每个终点可以到达的状态*被抽象成了一个二维点集*，每次寻找一堆点中的与某个点 $(a, b)$ 的点积最小值，显然这个最小值只能在点集的*下凸壳*中产生，并且是下凸壳的左半边，也就是说它不仅是凸壳， $x + y$ 还是递减的 ，如果维护了下凸壳可以二分或者三分求出极值（实际上分析下来跑暴力也可以）。

转移的话就是每个点暴力将自己的凸壳与能到达的点的凸壳双指针合并，那么这么做复杂度是什么？

题目中有这个条件，每条边的 $t - f <= 1000$ ，毛毛估一下复杂度肯定在 $O(1000N)$ 之内，#strike[可以开冲了]，考虑这个转移过程，如果一个点只是被一个点转移了，它的凸壳就是继承来的，没有变化；如果一个点被多个点转移，留下的是与起点距离不同的点，还要是组成凸壳的点，这些限制就很强了，这张图实际上是难以汇集出一个大凸壳的，数据要让复杂度高，一定是先生成一个大凸壳然后在一条链上不断转移，而在限制条件下，造出这个大凸壳本身需要很多代价，数据是造一个倒着的，偏的扫把，这个过程显然前半段需要 $n^2$ 数量级的边，后半段则是 $n$ ，所以平衡一下数据最劣可以做到 $O(N * N^(2\/3))$ ，题解的复杂度应该是这么来的。

当然由于是维护半个下凸壳，所以凸包实际跑起来很小，我的实现只跑了 46ms 

为了防止 mle ，可以利用边的条件，状态转移中*最多只有 1001* 个状态有用，所以只需要维护这么多凸壳，可以给编号取模来映射对应的凸壳，询问则是离线下来边转移边求答案。

下面是一份自认为比较优秀的实现

#zebraw(
```cpp
bool ccw(PII x, PII y) { return x.fi * y.se - x.se * y.fi <= 0; }
struct convex {
  vc<PII> a;
  convex(int N) { a.reserve(N); }
  PII &operator[](int i) { return a[i]; }

  void add(PII x) {
    if (not a.empty() and a.back().se <= x.se) return;
    while (len(a) > 1) {
      PII i = a.end()[-2], k = a.end()[-1];
      k = {k.fi - i.fi, k.se - i.se};
      i = {x.fi - i.fi, x.se - i.se};
      if (ccw(k, i)) a.pop_back();
      else break;
    }
    a.ep(x);
  }
};
void Yorisou() {
  INT(N, M);
  vvc<int> v(N);
  FOR(M) {
    INT(x, y, c);
    --x, --y;
    v[x].ep(y << 1 | c);
  }

  INT(Q);
  vc<int> ans(Q);
  vvc<T3<int>> qs(N);
  FOR(i, Q) {
    INT(a, b, t);
    --t;
    qs[t].ep(a, b, i);
  }

  convex t(N);
  Z merge = [&](convex &a, convex &b) {
    t.a.clear();
    int i = 0, k = 0, N = len(a.a), M = len(b.a);
    for (; i < N and k < M;) {
      if (a[i].fi != b[k].fi) {
        if (a[i].fi < b[k].fi) t.add(a[i++]);
        else t.add(b[k++]);
      } else {
        t.add(min(a[i], b[k]));
        ++i, ++k;
      }
    }
    for (; i < N; ++i) t.add(a[i]);
    for (; k < M; ++k) t.add(b[k]);
    b.a.resize(len(t.a));
    copy(all(t.a), b.a.begin());
  };
  
  vc<convex> hull(1001, convex(N));
  hull[0].add({0, 0});
  FOR(n, N) {
    int p = n % 1001;
    for (Z [a, b, i] : qs[n]) {
      ans[i] = fibonacci_search<int>([&](int i) {
        return a * hull[p][i].fi + b * hull[p][i].se;
      }, 0, len(hull[p].a)).fi;
    }
    for (int e : v[n]) {
      int x = e >> 1, c = e & 1;
      for (Z &x : hull[p].a) ++(c ? x.se : x.fi);
      merge(hull[p], hull[x % 1001]);
      for (Z &x : hull[p].a) --(c ? x.se : x.fi);
    }
    hull[p].a.clear();
  }
  FOR(i, Q) print(ans[i]);
}
```
)

== E

枚举右端点，每次新增一种颜色，单看这种颜色产生的*不可行区间会右移一段*，而所有颜色不可行区间取并，剩下的可以计入答案，问题是如何维护这样的信息。

可以使用线段树，用区间加 1 来表示某一段被标记为不合法，区间减 1 表示这段一种颜色由不合法变合法，这样可行的就是 0 段，所以实际上要做的是，区间加，区间查询 0 的个数，我这里是维护 *区间最小值和最小值出现次数* 来达到这个效果。

#zebraw(
```cpp
void Yorisou() {
  INT(N, K);
  VEC(int, a, N);
  int sz = QMAX(a);
  for (int &x : a) --x;
  vvc<int> v(sz);
  vc<int> p(N);
  FOR(i, N) v[a[i]].ep(i), p[i] = len(v[a[i]]) - 1;
  ll ans = 0;
  lazy_seg<a_monoid_mincnt_add<int>> seg(N, [&](int) { return PII(0, 1); });
  FOR(i, N) {
    int x = a[i], id = p[i];
    if (id >= K) {
      int l = id - K ? v[x][id - K - 1] + 1 : 0, r = v[x][id - K] + 1;
      seg.apply(l, r, -1);
    }
    if (id + 1 >= K) {
      int l = id - K > -1 ? v[x][id - K] + 1 : 0, r = v[x][id - K + 1] + 1;
      seg.apply(l, r, 1);
    }
    Z [mn, c] = seg.prod(0, i + 1);
    if (mn == 0) ans += c;
  }
  print(ans);
}
```
)

== F

高精度

首先每段的长度是比较平均的，不会偏太多，调整一下会发现相邻段长度不会差超过 1 ，可以开始搜索了

#zebraw(
```cpp
using G = bigint;
bool cp(const G &a, const G &b) {
  if (len(a.a) != len(b.a)) return len(a.a) > len(b.a);
  int sz = len(a.a) - 1;
  return a.a[sz] > b.a[sz];
}
void Yorisou() {
  int N, K;
  string str;
  IN(N, K, str);
  int B = N / (K + 1);
  G ans = str, t;
  for (int z : {-1, 0}) {
    vc<int> g;
    int U = 1;
    FOR(K) U *= 3;
    FOR(s, U) {
      g.clear();
      int xx = s, ss = 0;
      bool o = 1;
      FOR(K) {
        int x = xx % 3;
        xx /= 3;
        x = B + x + z;
        g.ep(x);
        ss += x;
      }
      g.ep(N - ss);
      FOR(i, 1, K + 1) if (abs(g[i] - g[i - 1]) > 1) o = 0;
      if (not o or QMIN(g) <= 0) continue;
      t = 0;
      int l = 0;
      FOR(i, K + 1) {
        int sz = g[i];
        t += G(str.substr(l, sz));
        if (cp(t, ans)) break;
        l += sz;
      }
      if (t < ans) ans = t;
    }
  }
  print(ans);
}
```
)

#pagebreak()

== H

签到题

算一下 k 进行几轮能用一次

#zebraw(
```cpp
void Yorisou() {
  LL(l, r, b, k);
  print(b * ceil(l, b) * k);
}
```
)

== I

神秘板子题，也可能是这题出了才成为板子

可以通过二进制分层（？）来框定离某点最近的几个点，从大层向下沉，处理完之后离线处理询问，进行大量区间 chmax 和单点查询完成答案更新

#zebraw(
```cpp
void Yorisou() {
  INT(N, Q);
  VEC(PII, a, N);
  VEC(PII, q, Q);
  FOR(i, Q) --q[i].fi;
  range_closest_pair g(a, q);
  for (ll s : g.f()) print(s);
)
```
)
== K

签到题

取模操作可以将 $x$ 变为 $[1, (x - 1)/2]$ 范围的任意数，如果 x 为偶数，它的一半本身就是一个因子，所以一个答案候选是最小值的一半，还有一种特殊情况是最小值是所有数的因子，特判一下

#zebraw(
```cpp
void Yorisou() {
  INT(N);
  VEC(int, a, N);
  sort(a);
  int ans = a[0] / 2;
  bool o = 1;
  FOR(i, 1, N) o &= a[i] / 2 >= a[0] or a[i] % a[0] == 0;
  if (o) chmax(ans, a[0]);
  print(ans);
}
```
)

#pagebreak()

== L

数字肯定优先删大的，不删会形成阻碍，操作肯定优先用大的，小的限制更优一些，所以将要被删的数排个序，直接模拟一个一个删，用两棵线段树维护信息，max 线段树用来二分找可操作的左右端点，另一个用于查询区间内剩几个数。

#zebraw(
```cpp
void Yorisou() {
  INT(N, M, K);
  VEC(int, a, N);
  VEC(int, b, M);
  VEC(int, l, K);

  vc<int> I;
  int i = 0, k = 0;
  for (; i < N; ++i) {
    if (k < M and a[i] == b[k]) ++k;
    else I.ep(i);
  }
  if (k != M) return NO();
  sort(I, [&](int i, int k) { return a[i] > a[k]; });

  multiset<int> se{all(l)};
  Seg<monoid_add<int>> c(N, [&](int) { return 1; });
  Seg<monoid_max<int>> seg(a);
  for (int i : I) {
    int x = a[i];
    int l = seg.min_left([&](int s)  { return s <= x; }, i);
    int r = seg.max_right([&](int s)  { return s <= x; }, i);
    int ct = c.prod(l, r);
    Z it = se.upper_bound(ct);
    if (it == se.begin()) return NO();
    --it;
    se.extract(it);
    seg.set(i, -1);
    c.set(i, 0);
  }
  YES();
}
```
)