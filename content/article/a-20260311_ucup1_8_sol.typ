#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 1st Universal Cup. Stage 8: Slovenia",
  desc: [ucup 1-8 训练记录],
  date: "2026-03-11",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.sol,
    blog-tags.rec,
  ),
  show-outline: true,
)

#show raw.where(block: true, lang: "cpp"): it => zebraw(
  numbering: true,
  it,
)

#set text(size: 8pt)

= The 1st Universal Cup. Stage 8: Slovenia

== 鲜花

感觉挺简单的, 不知道为什么有些简单题过的人不多, 排名莫名其妙在很前面 

== A - Bandits

#HL[题意]

一个带边权树, 每次给一个邻域内的边全部加上 1 积分, 或者询问某条边的积分 ($N, Q <= 10^5$)

#HL[解答]

离线下来建个点分树, 用一个自己喜欢的能单点加区间查询的结构维护积分

```cpp
void Yorisou() {
  INT(N);
  VEC(T3<int>, es, N - 1);
  graph g(N);
  for (Z &[x, y, w] : es) {
    --x, --y;
    g.add(x, y, w);
  }
  g.build();
  nearr<int, ll, ll> ds(g);
  
  INT(Q);
  vc<PII> q(Q);
  FOR(i, Q) {
    CH(op);
    if (op == '+') {
      INT(x, r);
      q[i] = {x, r};
      ds.addpos(x - 1, r);
    } else {
      INT(x);
      q[i] = {-x, 0};
    }
  }
  ds.build();
  for (Z [x, r] : q) {
    if (x < 0) {
      x = -x - 1;
      Z [f, t, w] = es[x];
      print(ds.prod(f, t, w));
    } else {
      --x;
      ds.add(x, r, 1);
    }
  }
}
```

#pagebreak()

== B - Combination Locks

#HL[题意]


Alice 和 Bob 正在玩组合锁。每个人都有一个由 $N$ 个可旋转数字盘组成的组合锁，每个数字盘上刻有 $0$ 到 $9$ 的数字。他们的朋友 Charlie 没有锁，于是设计了一个游戏让他们消遣。他会记录他们锁上对应数字是否相同，并用一个差异模式字符串 $S$ 来描述当前情况。$S$ 的第 $j$ 个字符要么是 '='，要么是 '.'，分别表示 Alice 和 Bob 的锁的第 $j$ 个数字是否相同。

Charlie 负责裁判，Alice 和 Bob 轮流操作，Alice 先手。每次操作时，玩家必须改变自己组合锁上的一个数字。由于 Charlie 只记录差异模式，因此一次有效的操作必须使差异模式发生变化。他还非常迷信，带来了一份不能在游戏过程中出现的模式列表 $P_i$。Charlie 的主要任务是确保在游戏过程中没有差异模式重复出现。无法进行有效操作的玩家判负。

#HL[解答]

将各位相等和不等的状态用 01 串表示, 每个 ban 掉的串都是禁止通行的状态, 与起始状态 xor 后就是一个从 0 点开始的 有一些点被 ban 了的图上博弈, 而相邻的点只有一个 bit 不同, 意味着这是一个二分图博弈, 所以 Alice 获胜的条件就是 0 点必须在每个最大匹配上

```cpp
void Yorisou() {
  INT(N, M);
  STR(a, b);
  int s = 0;
  FOR(i, N) if (a[i] == b[i]) s |= 1 << i;
  vc<u8> vis(1 << N);
  FOR(i, M) {
    int t = 0;
    STR(str);
    FOR(k, N) if (str[k] == '=') t |= 1 << k;
    t ^= s;
    vis[t] = 1;
  }
  graph g(1 << N);
  FOR(s, 1 << N) if (not vis[s]) {
    FOR(k, N) if (not(s >> k & 1) and not vis[1 << k | s]) {
      g.add(s, 1 << k | s);
    }
  }
  g.build();
  int mx = len(B_matching(g).matching());
  g = graph(1 << N);
  FOR(s, 1, 1 << N) if (not vis[s]) {
    FOR(k, N) if (not(s >> k & 1) and not vis[1 << k | s]) {
      g.add(s, 1 << k | s);
    }
  }
  g.build();
  int ne = len(B_matching(g).matching());
  Alice(mx != ne);
}
```

#pagebreak()

== C - Constellations

#HL[题意]

二维平面上初始有 $N$ 个点, 各为一个点集, 点集会不断合并, 每次合并距离最近的, 每次输出合并出的新星系的点集大小, 点集距离的定义是 两个点集所有点对的距离的平均值

#HL[解答]

可以将所有边扔到一个小根堆里, 每次合并后新增 $O(N)$ 条边

```cpp
using P = PLL;
ll sq(ll x) { return x * x; }
ll dist(P a, P b) { return sq(a.fi - b.fi) + sq(a.se - b.se); }
struct dat {
  ll dis, sz;
  int a, b, l, r;
  bool operator<(const dat &p) const {
    ll ls = dis * p.sz, rs = p.dis * sz;
    if (ls != rs) return ls < rs;
    return a > p.a or (a == p.a and b > p.b);
  }
  bool operator>(const dat &p) const { return p < *this; }
};
void Yorisou() {
  INT(N);
  VEC(P, a, N);
  retsu<ll> dis(N, N);
  FOR(i, N) FOR(k, i + 1, N) dis[i][k] = dis[k][i] = dist(a[i], a[k]);
  vc<int> sz(N, 1);
  vc<int> t(N);
  FOR(i, N) t[i] = N - i - 1;
  int tt = 0;
  vc<u8> vis(N, 1);
  min_heap<dat> q;
  FOR(i, N) FOR(k, i + 1, N) {
    int l = i, r = k;
    if (t[l] < t[r]) swap(l, r);
    q.eb(dat{dis[l][r], 1, t[l], t[r], l, r});
  }
  while (not q.empty()) {
    Z [_, __, a, b, l, r] = pop(q);
    if (t[l] != a or t[r] != b) continue;
    vis[r] = 0;
    print(sz[l] + sz[r]);
    sz[l] += sz[r];
    t[l] = --tt;
    t[r] = N + 1;
    FOR(i, N) if (vis[i] and i != l) {
      dis[l][i] += dis[r][i];
      dis[i][l] = dis[l][i];
      q.eb(dat{dis[l][i], sz[l] * sz[i], t[i], t[l], i, l});
    }
  }
}
```

#pagebreak()

== D - Deforestation

#HL[题意]

有一个树, 每个节点都是一个木棍, 将树切割成若干个长度不超过 $K$ 的连通块, 求最少连通块数量

#HL[解答]

从下往上删除, 如果一个节点的子节点连通块大小和超过了 $K$ , 一定要切出一个单独的连通块, 所以将最大的切了, 直到和不超过 $K$, 这时这个节点和子连通块可以看作一个棍子, 将超出的部分切了, 剩下的传上去

```cpp
void Yorisou() {
  LL(W);
  vc<vc<int>> v;
  vc<ll> c;
  Z ge = [&](Z &ge, int n, int f) -> void {
    if (f != -1) v[f].ep(n);
    INT(w, sz);
    v.ep();
    c.ep(w);
    v[n].reserve(sz);
    FOR(sz) ge(ge, len(c), n);
  };
  ge(ge, 0, -1);
  ll ans = 0;
  Z f = [&](Z &f, int n) -> ll {
    vc<ll> s;
    for (int x : v[n]) {
      ll nx = f(f, x);
      if (nx != 0) s.ep(nx);
    }
    sort(s);
    ll sm = SUM(s);
    while (sm >= W) sm -= pop(s), ++ans;
    c[n] += sm;
    ans += c[n] / W;
    c[n] %= W;
    return c[n];
  };
  ll s = f(f, 0);
  print(ans + ceil(s, W));
}
```

#pagebreak()

== E - Denormalization

#HL[题意]

给一个被归一化了的向量, 原向量值域 $[1, 10^4]$, 长度 $N <= 10^4$

#HL[解答]

相当于给出了各个数字之间的比例, 可以枚举最小值, 小数部分与整数误差最小的作为答案

```cpp
using re = ld;
void Yorisou() {
  INT(N);
  VEC(re, a, N);
  re m = QMIN(a);
  for (re &x : a) x /= m;
  re mn = inf<re>;
  int ai = -1;
  FOR(i, 1, 10001) {
    re mx = 0;
    for (re x : a) {
      x *= i;
      chmax(mx, abs(x - round(x)));
    }
    if (chmin(mn, mx)) ai = i;
  }
  FOR(k, N) print(ll(round(a[k] * ai)));
}
```

#pagebreak()

== F - Combination Locks

神秘题, vp 时候第二个过的题, 还以为是签到就乱编了个做法冲过去

#HL[题意]

$N$ 个长度 $M$ 的仅有 ABCD 字母的串($N * M <= 2*10^7$), 其中一个串和其他串的距离都是 $k$ , 找出这个串, 距离的定义是相同位置不同的字符数量

#HL[解答]

- 如何快速求两个串距离

可以用两个 bit 表示一个字符, 这样可以将连续 $32$ 个字符塞进一个 ull 中, 如果将第一位放在前 $32$ bit, 第二位放在后 $32$ bit , 令 $a:= s_i [0, 15], b := s_k [0, 15]$ 这样连续 32 个字符的距离就是 ```cpp popcount<uint>((a ^ b) | ((a ^ b) >> 32))```

- 如何随机出特殊串

维护这样两个集合, A 内是可能为答案的串, B 内是已经确定不是特殊串的串

先从 A 中随机找一个串出来, 求它和其他串的距离, 如果为 K 就还是可能的串, 否则扔进 B 中

之后不断从 B 中 popback 出一个确定不是答案的串, 求它和 A 中串的距离, 将不为 K 的淘汰掉, 继续放入 B 中

单纯这样一直淘汰 A 中的串, 已经可以通过一部分测试点, 但最终会在一些testcase无法淘汰所有错误的串 , 这个时候肯定已经淘汰了相当一部分串, 也就是说 A 集合中可能为答案的串已经不多了, 这个时候就反过来, 开始在 A 中随机可能的特殊串, 将它和所有串进行匹配, 随出答案就停止

但这样做还是会在靠后的测试点 tle , 可以使用指令集加速, 最终能在 1s 内冲过去

```cpp
struct dat {
  vc<ull> a;
  void from_s() {
    STR(s);
    int N = len(s);
    while (N % 32) ++N, s += 'A';
    for (char &c : s) c -= 'A';
    a.resize(N >> 5);
    FOR(i, N >> 5) {
      FOR(k, 32) {
        ull l, r;
        char c = s[i << 5 | k];
        l = not(c & 1);
        r = not(c & 2);
        a[i] |= l << (32 + k);
        a[i] |= r << k;
      }
    }
  }
  
  int count(const dat &p) const {
    int N = len(a), s = 0;
    FOR(i, N) {
      ull x = a[i] ^ p.a[i];
      s += pc(uint(x | (x >> 32)));
    }
    return s;
  }
};
void Yorisou() {
  INT(N, M, K);
  vc<dat> s(N);
  FOR(i, N) s[i].from_s();
  vc<int> A, B;
  int p = rng(N);
  Z ck = [&](const dat &a, const dat &b) -> bool {
    return a.count(b) == K;
  };
  FOR(i, N) if (i != p) {
    if (ck(s[i], s[p])) A.ep(i);
    else B.ep(i);
  }
  if (len(A) == N - 1) return print(p + 1);
  vc<int> C;
  C.ep(p);
  while (len(A) > 1) {
    if (not B.empty()) {
      p = pop(B);
      C.ep(p);
      vc<int> aa;
      for (int i : A) {
        if (ck(s[i], s[p])) aa.ep(i);
        else B.ep(i);
      }
      A.swap(aa);
    } else {
      p = pop(A);
      bool ok = 1;
      for (int i : A) {
        if (not ck(s[i], s[p])) {
          ok = 0;
          break;
        }
      }
      if (not ok) {
        C.ep(p);
        continue;
      }
      for (int i : C) {
        if (not ck(s[i], s[p])) {
          ok = 0;
          break;
        }
      }
      if (not ok) {
        C.ep(p);
        continue;
      }
      return print(p + 1);
    }
  }
  print(A[0] + 1);
}
```

#pagebreak()

== G - Greedy Drawers

感觉这题不太简单吧, 赛时过的人也不怎么多, luogu 上可能乱评了个低分

#HL[题意]

有 $N in [150, 250]$ 本书以及书柜, 每个柜子放一本书, 它们都是矩形, 当书本长宽 $<=$ 书柜长宽时能放进去, 题目提供了这样一个随机放书的策略: 每次取能放的书柜最少的书, 或能存最少书的书柜, 然后从它可选的对象中随机选一个匹配, 需要构造一个方案, 输出书本和书柜大小, 使题目中这个策略在全部 20 个测试点中失败

#HL[解答]

可以看草稿中这个构造, 圆点表示书, 方点表示书柜, 对于这个部分, 度数最少的只有中间一个圆点, 只要它匹配到左边的方点, 策略就炸了, 所以可以重复造这样的大小只有 6 的结构, 失败概率 $1 / 2^25$

#figure(image("/public/imgss/ucup1_8_0.png", alt: "yorisou"), caption: "赛时草稿")

```cpp
void Yorisou() {
  INT(N);
  vc<PII> b, a;
  int l = 1, r = 1000;
  while (len(b) < N) {
    b.ep(l, r);
    b.ep(l, r);
    a.ep(l, r);
    a.ep(l, r);
    a.ep(l, r);
    ++l;
    b.ep(l, r);
    --r;
    a.ep(l, r);
    ++l;
    b.ep(l, r);
    --r;
    a.ep(l, r);
    a.ep(l, r);
    b.ep(l, r);
    b.ep(l, r);
    ++l, --r;
  }
  sh(b, N);
  sh(a, N);
  for (Z [x, y] : a) print(x, y);
  for (Z [x, y] : b) print(x, y);
}
```

#pagebreak()

== H - Insertions

大汾题, 看了就不想写, 扔了

#HL[题意]

#HL[解答]

```cpp

```

#pagebreak()

== I - Money Laundering

#HL[题意]

有一张 $N + M$ 个点的有向图($N, M <= 1000$), 每条边有个比率 $p in [0.0, 1.0]$, 问从每个点出发, 将 1 点积分转移到所有编号在 $[N, N + M)$ 的点, 每个终点收到的积分

#HL[解答]

如果没有环, 逆拓扑序暴力处理每个点向终点转移的比率即可, 有环的话需要 scc 缩点, 环内用求逆或者快速幂(大量转移处理至精度足够)处理出正确的转移比率, 再向终点转移, 主要难度在于各个环节处理有点复杂, 码量有点大

```cpp
using re = ld;
void Yorisou() {
  INT(N, M);
  graph<re, 1> g(N);
  vc<int> in(N);
  vc<tuple<int, int, re>> es;
  FOR(i, N) {
    INT(sz);
    FOR(sz) {
      STR(s);
      int c = s.find(":");
      string a = s.substr(1, c - 1), b = s.substr(c + 1);
      int t = stoi(a);
      --t;
      re p = stold(b) / 100;
      if (s[0] == 'P') t += N;
      es.ep(i, t, p);
      if (t < N) ++in[t], g.add(i, t, p);;
    }
  }
  g.build();
  Z [T, id] = scc(g);
  g = graph<re, 1>(N + M);
  for (Z [f, t, w] : es) g.add(f, t, w);
  g.build();

  vc<vc<int>> v(T);
  FOR(i, N) v[id[i]].ep(i);
  sh(id, N + M);
  fill(all(id), -1);
  retsu<re> dp(N, M);
  FOR_R(i, T) {
    int sz = len(v[i]);
    FOR(k, sz) id[v[i][k]] = k;
    mat<re> to(sz << 1);
    vc<re> ss(sz);
    FOR(k, sz) {
      int f = v[i][k];
      re s = 0;
      for (Z &&e : g[f]) {
        if (id[e.to] != -1) to[k][id[e.to]] = e.w;
        else s += e.w;
      }
      to[k][k + sz] = s;
      ss[k] = s;
    }
    FOR(i, sz) to[i + sz][i + sz] = 1;
    FOR(15) to *= to;
    FOR(k, sz) {
      int f = v[i][k];
      FOR(j, sz) if (ss[j] != 0) {
        int m = v[i][j];
        re st = to[k][j + sz] / ss[j];
        for (Z &&e : g[m]) if (id[e.to] == -1) {
          if (e.to >= N) {
            dp[f][e.to - N] += e.w * st;
          } else {
            FOR(l, M) dp[f][l] += dp[e.to][l] * e.w * st;
          }
        }
      }
    }
    for (int x : v[i]) id[x] = -1;
  }

  setp(6);
  FOR(i, N) FOR(k, M) cout << dp[i][k] << " \n"[k + 1 == M];
}
```

#pagebreak()

== J - Mortgage

不知道为啥过的人不多, 挺简单的, 码量也小

#HL[题意]

给你一个收入数列, 表示当天赚了或亏了多少, 每次给你一个区间, 问你从这个区间起点开始至终点, 你最多可以每天花费多少钱, 同时每天的存款不能低于0

#HL[解答]

将收入数列做一个前缀和, 每次询问实际上就是要找从起点开始到区间内哪个点连线的斜率最小, 求这个最小斜率, 观察或者画图或者直接发挥记忆力可以知道, 这个斜率最低点一定是这段点形成的下凸壳上的某一点, 知道下凸壳的话可以在下凸壳上三分找到它, 维护下凸壳可以用线段树的结构, 将一个区间分成 log 段, 在每段中三分一个斜率最低点取 min

代码真的很短(

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

#pagebreak()

== K - Skills in Pills 

#HL[题意]

$N$ 个格子, 每 K 格都要有至少一个 a, 每 J 格至少要有一个 b, 问 a 和 b 共最少能放几个

#HL[解答]

枚举 a b 的初始位置然后贪心取最优解

```cpp
void Yorisou() {
  INT(k, j, N);
  if (k > j) swap(k, j);
  Z f = [&](int s) -> int {
    vc<u8> g(N + 1);
    int r = 1;
    g[s] = 1;
    s += j;
    while (s <= N) {
      g[s] = 1;
      ++r;
      s += j;
    }
    int rs = s - N - 1, st = 0;
    s = k;
    while (s <= N) {
      if (s + st <= N and g[s + st]) {
        if (rs) --rs, ++st;
        else --s;
      }
      ++r;
      s += k;
    }
    return r;
  };
  int s = inf<int>;
  FOR(i, max(1, j - 100), j + 1) chmin(s, f(i));
  swap(j, k);
  FOR(i, max(1, j - 100), j + 1) chmin(s, f(i));
  print(s);
}
```

#pagebreak()

== L - The Game 

#HL[题意]

就是一个打牌游戏, 给一个抽牌堆, 每回合按规则依次往四个牌堆之一出两张牌, 然后如果抽牌堆有牌就抽两张, 出不了或者手上没牌了就结束, 最后按顺序输出所有手上的牌堆里的抽牌堆里的所有牌

#HL[解答]

按照题目给的规则模拟

```cpp
void Yorisou() {
  VEC(int, a, 98);
  reverse(a);
  vc<int> q;
  FOR(8) q.ep(pop(a));
  vc<int> st[4];
  st[0] = st[1] = {1};
  st[2] = st[3] = {100};
  while (not q.empty()) {
    int cnt = 2;
    while (cnt) {
      vc<PII> bst;
      FOR(i, len(q)) {
        int x = q[i];
        FOR(k, 2) {
          if (st[k].back() - x == 10) bst.ep(i, k);
        }
        FOR(k, 2, 4) {
          if (x - st[k].back() == 10) bst.ep(i, k);
        }
      }
      if (not bst.empty()) {
        --cnt;
        Z [i, k] = bst[0];
        st[k].ep(q[i]);
        q.erase(bg(q) + i);
        continue;
      }
      int mx = inf<int>, ii = -1, kk;
      FOR(i, len(q)) {
        int x = q[i];
        FOR(k, 2) {
          if (st[k].back() < x and chmin(mx, x - st[k].back())) ii = i, kk = k;
        }
        FOR(k, 2, 4) {
          if (st[k].back() > x and chmin(mx, st[k].back() - x)) ii = i, kk = k;
        }
      }
      if (mx == inf<int>) break;
      st[kk].ep(q[ii]);
      q.erase(bg(q) + ii);
      --cnt;
    }
    if (cnt) break;
    FOR(2) if (not a.empty()) q.ep(pop(a));
  }
  reverse(a);
  FOR(i, 4) print(st[i]);
  print(q);
  print(a);
}
```

#pagebreak()