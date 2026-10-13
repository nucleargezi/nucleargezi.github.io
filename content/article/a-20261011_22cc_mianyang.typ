#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record CCPC 2022 Mianyang Site",
  desc: [2022 ccpc 绵阳 训练记录],
  date: "2026-10-11",
  tags: ("icpc",),
  category: "ICPC",
)

= CCPC 2022 Mianyang Site

#link("https://qoj.ac/contest/1480", "Qoj Link")

== Hitokoto

2022 绵阳区域赛, 出题组都是眼熟的上一代选手

== A. Ban or Pick, What's the Trick
- In-Contest Solves: 117/687 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8034/statement/zh_cn")

=== Formal Problem Statement

两名玩家 $A, B$ 各有 $N$ 个英雄, 权值分别为 $a_1, dots, a_N$ 和 $b_1, dots, b_N$, 两人的英雄池互不相交

$A$ 先手, 双方轮流操作, 每次任选一种操作

- 从自己的英雄池中选取一个尚未被选择或禁用的英雄, 归自己所有
- 从对方的英雄池中禁用一个尚未被选择或禁用的英雄, 使其之后无法被选择

共进行 $2N$ 次操作, 直到所有英雄都被选择或禁用, 然后双方分别从自己选到的英雄中取至多 $K$ 个组成阵容, 阵容得分为所取英雄的权值和

记双方得分为 $s_A, s_B$, $A$ 希望最大化 $s_A - s_B$, $B$ 希望最小化 $s_A - s_B$, 求双方均采取最优策略时的最终差值

=== Constraints

- $1 <= N <= 10^5$
- $1 <= K <= 10$
- $1 <= a_i, b_i <= 10^8$, 均为整数

=== Solution

K 很小, 所以可以直接 dp , dp[i][x][y] 表示第 i 轮, A 选了 x 个, B 选了 y 个的最优情况, A, B 选到的 pos 可以直接通过 i, x, y 计算; 将 a, b 从大到小排序后直接 dp

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"

constexpr int n = 11;

void Yorisou() {
  INT(N, K);
  VEC(int, a, N);
  VEC(int, b, N);
  sort(a, greater());
  sort(b, greater());
  vc<array<array<ll, n>, n>> dp(N << 1);
  FOR(i, N << 1) FOR(k, n) dp[i][k].fill(ine<ll>);
  Z f = [&](Z &f, int i, int x, int y) -> ll {
    if (i == N << 1) return 0;
    if (dp[i][x][y] != ine<ll>) return dp[i][x][y];
    if (~i & 1) {
      int t = x + (i / 2) - y;
      if (t < N and x < K) chmax(dp[i][x][y], a[t] + f(f, i + 1, x + 1, y));
      chmax(dp[i][x][y], f(f, i + 1, x, y));
    } else {
      int t = y + (i / 2) - x + 1;
      ll s = inf<ll>;
      if (t < N and y < K) chmin(s, -b[t] + f(f, i + 1, x, y + 1));
      chmin(s, f(f, i + 1, x, y));
      dp[i][x][y] = s;
    }
    return dp[i][x][y];
  };
  print(f(f, 0, 0, 0));
}

int main() { Yorisou(); }
```

== B. Call Me Call Me
- In-Contest Solves: 4/64 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8035/statement/zh_cn")

=== Formal Problem Statement

有 $N$ 个人, 编号为 $1, dots, N$, 初始均未加入集合 $S$

第 $i$ 个人对应区间 $[l_i, r_i]$ 和阈值 $k_i$, 仅当 $S$ 中已有至少 $k_i$ 个编号位于 $[l_i, r_i]$ 的人时, 才能将 $i$ 加入 $S$, 加入后不会退出

可以自行决定加入顺序, 求最终 $S$ 的最大大小

=== Constraints

- $1 <= N <= 4 dot 10^5$
- $1 <= l_i <= r_i <= N$
- $0 <= k_i <= N$, 不保证 $k_i <= r_i - l_i + 1$
- 所有输入均为整数

=== Solution

题意说的很明白了, 是个二进制报警器类似物, 但 watch 范围是一个区间

像线段树那样将每个区间拆成 log 个点, 然后扔二进制报警器上就做完了, add NlogN 次

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/ds/alarm/bina_alarm.hpp"

void Yorisou() {
  INT(N);
  bina_alarm<int> g(N << 1);
  vc<int> buf, q, to(N);
  FOR(i, N) {
    INT(l, r, k);
    --l;
    if (k == 0) q.ep(i);
    else {
      buf.clear();
      for (l += N, r += N; l < r; l >>= 1, r >>= 1) {
        if (l & 1) buf.ep(l++);
        if (r & 1) buf.ep(--r);
      }
      to[g.watch(buf, k)] = i;
    }
  }

  FOR(i, si(q)) {
    for (int x = q[i] + N; x; x >>= 1) {
      for (int s : g.add(x, 1)) q.ep(to[s]);
    }
  }
  print(si(q));
}

int main() { Yorisou(); }
```

== C. Catch You Catch Me
- In-Contest Solves: 314/429 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8036/statement/zh_cn")

=== Formal Problem Statement

给定一棵 $N$ 个点的树, 以 $1$ 为根, 初始时每个非根节点上恰有一只蝴蝶

每分钟所有尚未被捕获的蝴蝶同时向父节点移动一步, 到达根节点的蝴蝶立即消失, 无法再被捕获

一次操作可以选择任意非根节点, 捕获当时位于该节点的所有蝴蝶, 操作不耗时, 可以在同一时刻进行多次操作, 也可以在初始时刻操作

求在所有蝴蝶消失前将它们全部捕获所需的最少操作次数

=== Constraints

- $1 <= N <= 10^5$
- 输入 $N - 1$ 条边, 每条边的两个端点不同, 编号均在 $[1, N]$ 内
- 保证输入构成一棵树

=== Solution

对于根之下的每个子树, 同一深度的点尽量一起抓是最优的, 每个点最终都会移动到子树顶部, 所以一直在子树顶部抓就行, 答案为根连接的子树的深度之和

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/ttr/tr.hpp"

void Yorisou() {
  INT(N);
  vc<vc<int>> g(N);
  FOR(N - 1) {
    INT(a, b);
    --a, --b;
    g[a].ep(b), g[b].ep(a);
  }
  tr v(g, 0);
  vc<int> f(N);
  reverse(v.V);
  for (int n : v.V) {
    int p = v.fa[n];
    chmax(f[n], v.d[n]);
    if (p != -1) chmax(f[p], f[n]);
  }
  int s = 0;
  for (int x : g[0]) s += f[x];
  print(s);
}

int main() { Yorisou(); }
```

== D. Gambler's Ruin
- In-Contest Solves: 55/509 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8037/statement/zh_cn")

=== Formal Problem Statement

有 $N$ 名赌客, 第 $i$ 名赌客认为 $A$ 队获胜的概率为 $p_i$, 下注金额为 $c_i$, 比赛结果只能是 $A$ 队或 $B$ 队获胜

庄家可以为两队分别设置实数赔率 $x, y$, 赌客按照以下规则下注

- 若 $p_i x >= 1$, 向 $A$ 队下注 $c_i$
- 否则, 若 $(1 - p_i)y >= 1$, 向 $B$ 队下注 $c_i$
- 否则不下注

记两队收到的赌注总额分别为 $s_x, s_y$, 若 $A$ 队获胜, 庄家需赔付 $x s_x$, 否则需赔付 $y s_y$

选择 $x, y$, 使最坏情况下的利润 $s_x + s_y - max(x s_x, y s_y)$ 最大, 输出这个最大值

=== Constraints

- $1 <= N <= 10^6$
- $0 <= p_i <= 1$, 小数点后至多 $6$ 位
- $1 <= c_i <= 10^8$, $c_i$ 为整数
- 输出的绝对误差或相对误差不超过 $10^(-6)$

=== Solution

预处理出 x 和 y 的所有取值

顺序枚举 x , 计算每个 x 的最优值; 对于每个 x , $"ans" = f(y)$ 是凸的, 最优点 y 的取值也是递增的, 双指针求出每对 ${x, y}$ 取最优

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"

using re = ld;
using T = pair<re, int>;

void Yorisou() {
  INT(N);
  VEC(T, a, N);
  sort(a, greater());
  vc<ll> c(N + 1);
  FOR(i, N) c[i + 1] = a[i].se + c[i];

  vc<pair<re, int>> xs, ys;
  FOR(i, N) {
    if (i + 1 < N and a[i + 1].fi == a[i].fi) continue;
    var [p, ci] = a[i];
    xs.ep(p, i + 1);
  }
  FOR_R(i, N) {
    if (i - 1 >= 0 and a[i - 1].fi == a[i].fi) continue;
    var [p, ci] = a[i];
    ys.ep(1 - p, i);
  }
  
  int n = si(ys), pos = 0;
  Z w = [&](re p, int r, int k) -> re {
    var [yp, l] = ys[k];
    re x = 1 / p, sx = c[r];
    re y = 1 / yp, sy = c[N] - c[l];
    return sx + sy - max(sx * x, sy * y);
  };
  re rs = 0;
  FOR(i, n - 1) {
    var [p, r] = xs[i];
    int lm = n - i - 2;
    chmin(pos, lm);
    while (pos < lm and w(p, r, pos + 1) >= w(p, r, pos)) ++pos;
    chmax(rs, w(p, r, pos));
  }
  print(rs);
}

int main() { Yorisou(); }
```

== E. Hammer to Fall
- In-Contest Solves: 81/446 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8038/statement/zh_cn")

=== Formal Problem Statement

给定一个 $N$ 个点, $M$ 条边的无向带权图, 点 $i$ 初始有 $a_i$ 个人, 将一个人沿权值为 $w$ 的边移动一次需要支付 $w$ 的代价

已知接下来 $Q$ 天的落锤位置依次为 $b_1, dots, b_Q$, 第 $j$ 天落锤的瞬间, 位于点 $b_j$ 的所有人都会死亡

可以在落锤前后任意安排人员移动, 每个人可以移动任意多次, 多人可以同时移动, 落锤后的点仍可进入

求保证所有人存活所需的最小总代价, 输出其对 $998244353$ 取模的结果, 最小化的是取模前的代价

=== Constraints

- $2 <= N <= 10^5$, $1 <= M, Q <= 10^5$
- $1 <= a_i <= 10^9$
- 每条边的两个端点不同, 编号均在 $[1, N]$ 内, 边权满足 $1 <= w <= 10^9$
- 保证每个点至少与一条边相连
- $1 <= b_j <= N$, 所有输入均为整数

=== Solution

可以倒着 dp 每个点有一个人存活的最小代价, 一个会被锤子砸的点, 其状态由邻点转移而来

直接做的问题在于度数大的点的 dp 值需要从大量候选点转移过来, 考虑这样一种处理: 选出度数大于 B 的 big 点, 这里暂时将 B 看作 $sqrt(N)$, 这些点只会被更新至多 $N sqrt(N)$ 次; 所以可以进行这样的处理: 每当一个点的 dp 值更新完毕, 直接立刻对相邻的 big 点传入 dp 信息, 这些 big 点保存所有这些更新信息, 直到它们被锤子砸到, 处理出这些信息中最优的 dp 值进行更新

而非 big 点直接暴力更新, 将邻点扫一遍

现在唯一的问题是, 某个 big 点 n 的邻点可能在 n 的一次结算前被更新了多次, 旧的 dp 值不能使用, 得删掉, 所以需要一个支持添加删除元素, 查询最值的结构, 我用了可删堆

虽然复杂度带了个 log , 不过可以调大块长将 log 弄到根号里面, 这样复杂度 $O(N sqrt(N log N))$

实际上由于这是个点数边数规模相同的图, 根号应该是卡不满的, 我的 100ms 就跑完了

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/gg/bs.hpp"
#include "YRS/ds/heap/erase_heap.hpp"
#include "YRS/mod/mint.hpp"

using T = M99;

constexpr int B = 800;

void Yorisou() {
  INT(N, M, Q);
  VEC(int, a, N);
  vc<vc<edge_w<int>>> g(N);
  vc<int> in(N);
  FOR(M) {
    INT(a, b, c);
    --a, --b;
    ++in[a], ++in[b];
    g[a].ep(b, c), g[b].ep(a, c);
  }
  vc<char> vis(N);
  FOR(i, N) if (in[i] >= B) vis[i] = 1;
  vc<vc<edge_w<int>>> ch(N);
  FOR(n, N) for (var [x, w] : g[n]) if (vis[x]) ch[n].ep(x, w);
  
  vc<ll> dp(N);
  vc<min_erase_heap<ll>> q(N);
  FOR(n, N) for (var [x, w] : ch[n]) q[x].eb(w);
  VEC(int, b, Q);
  reverse(b);
  for (int &n : b) {
    --n;
    for (var [x, w] : ch[n]) q[x].pop(dp[n] + w);
    if (vis[n]) {
      ll nx = q[n].top();
      dp[n] = nx;
    } else {
      ll nx = inf<ll>;
      for (var [x, w] : g[n]) chmin(nx, dp[x] + w);
      dp[n] = nx;
    }
    for (var [x, w] : ch[n]) q[x].eb(dp[n] + w);
  }
  T s = 0;
  FOR(i, N) s += T(dp[i]) * a[i];
  print(s);
}

int main() { Yorisou(); }
```

== G. Let Them Eat Cake
- In-Contest Solves: 316/526 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8040/statement/zh_cn")

=== Formal Problem Statement

给定一个长度为 $N$ 的排列 $a$

每一轮同时删除所有满足以下条件的元素: 在当前序列中, 至少有一个相邻元素比它大, 两端的元素只考虑唯一的邻居

删除后剩余元素保持原有相对顺序, 并重新相邻, 重复操作直到只剩一个元素

求进行的轮数, 最后剩下的元素不再额外计一轮, 因而 $N = 1$ 时答案为 $0$

=== Constraints

- $1 <= N <= 10^5$
- $1 <= a_i <= N$, 所有 $a_i$ 两两不同

=== Solution

所有元素互不相同, 说明每次相邻两个点至少会被删一个, 直接模拟, 至多 $log$ 轮结束

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"

void Yorisou() {
  INT(N);
  VEC(int, a, N);
  int s = 0;
  while (si(a) > 1) {
    int n = si(a);
    vc<char> vis(n);
    FOR(i, n) {
      if (i and a[i - 1] > a[i]) vis[i] = 1;
      if (i + 1 < n and a[i + 1] > a[i]) vis[i] = 1;
    }
    vc<int> b;
    FOR(i, n) if (not vis[i]) b.ep(a[i]);
    a.swap(b);
    ++s;
  }
  print(s);
}

int main() { Yorisou(); }
```

== H. Life is Hard and Undecidable, but...
- In-Contest Solves: 298/449 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8041/statement/zh_cn")

=== Formal Problem Statement

在无限整数网格上进行生命游戏, 每个格点处于存活或死亡状态, 邻居为横向, 纵向和对角方向相邻的 $8$ 个格点

每一代根据上一代的状态同时更新所有格点

- 死亡格点恰有 $3$ 个存活邻居时变为存活, 否则仍然死亡
- 存活格点有 $2$ 或 $3$ 个存活邻居时继续存活, 否则变为死亡

给定正整数 $N$, 构造第 $0$ 代的有限非空存活格点集合, 其余格点均死亡, 使第 $N - 1$ 代仍有存活格点, 第 $N$ 代所有格点均死亡

输出初始存活格点数及其坐标, 任意满足条件的构造均可, 保证有解

=== Constraints

- $1 <= N <= 100$
- 初始存活格点数在 $[1, 90000]$ 内
- 每个初始存活格点的整数坐标满足 $1 <= x_i, y_i <= 300$, 坐标对两两不同
- 坐标范围只限制初始构造, 演化始终发生在无限网格上

=== Solution

虽然不太懂生命游戏, 但规则比较简单, 稍微手玩一下也能很快弄出来

新增和存活的条件其实是比较强的, 考虑是否能造一个每回合变短一点, 最终消失的结构, 模拟几组边界状态能很快玩出这样的结构:

```
.......x.
.....x.x.
...x.x...
.x.x.....
.x.......
```
```
......x..
....x....
..x...x..
....x....
..x......
```
```
.........
.....x...
...x.x...
...x.....
.........
```

但好像其实直接造一条斜线就行了

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"

void Yorisou() {
  INT(N);
  print(2 * N);
  FOR(i, N) {
    print(1 + 2 * i, 1 + i);
    print(1 + 2 * i, 2 + i);
  }
}

int main() { Yorisou(); }
```

== K. Pattern Matching in A Minor "Low Space"
- In-Contest Solves: 0/298 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8044/statement/zh_cn")

=== Formal Problem Statement

给定长度分别为 $N, M$ 的字符串 $s, t$, 求 $s$ 在 $t$ 中作为连续子串出现的次数, 不同出现位置可以重叠

输入依次给出 $N, M$, 模式串 $s$ 和文本串 $t$, 只能按照输入顺序读取一次, 不能回退输入流或重新读取, 必须读完全部输入后才能输出答案

=== Constraints

- $1 <= N, M <= 10^7$
- $s, t$ 仅包含小写英文字母
- 题面特别注明内存限制为 1 MB
- 时间限制为 5 s

=== Solution

论文题, 实现题解的 $O(sqrt(N))$ 空间做法或者论文中的 $O(log N)$ 做法都可以通过

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/string/match_sqrt.hpp"

void Yorisou() {
  INT(N, M);
  match_sqrt s(N, [&](int i) { 
    CH(c);
    c -= 'a';
    return c;
  });
  int rs = 0;
  FOR(M) {
    CH(c);
    c -= 'a';
    rs += s.add(c);
  }
  print(rs);
}

int main() { Yorisou(); }
```

== L. Por Una Cabeza
- In-Contest Solves: 138/150 (qoj)
- #link("https://qoj.ac/contest/1480/problem/8045/statement/zh_cn")

=== Formal Problem Statement

有 $N$ 名观众和 $M$ 台投票机, 分别按 $1, dots, N$ 和 $1, dots, M$ 编号, 观众按编号递增的顺序依次投票

第 $i$ 名观众原本投 $a_i in {0, 1}$, 可以支付 $b_i$ 的代价将其投票翻转

第 $j$ 台投票机有奇数个输入, 每个输入来自一名观众或一台编号小于 $j$ 的投票机, 每名观众的投票以及除第 $M$ 台外每台投票机的输出, 都恰好被一台投票机使用一次, 第 $M$ 台的输出为最终结果

一台有 $ell$ 个输入的投票机, 一旦收到至少 $(ell + 1) / 2$ 个相同的值, 就立即输出该值

要求通过付费翻转部分观众的投票, 使每台投票机都恰好收到全部输入后才输出, 最终结果为 $0$ 或 $1$ 均可

有 $Q$ 次永久修改, 每次给定 $(i, x, y)$, 将 $a_i$ 改为 $x$, $b_i$ 改为 $y$, 在每次修改后独立求满足要求的最小翻转总代价, 求解时选择的翻转不影响后续修改

=== Constraints

- $1 <= N, M, Q <= 10^5$
- $a_i in {0, 1}$, $1 <= b_i <= 10^9$
- 第 $j$ 台投票机的输入数 $ell_j$ 为奇数, $1 <= ell_j <= N + M - 1$, 所有投票机的输入数之和为 $N + M - 1$
- 输入编号 $c > 0$ 表示第 $c$ 名观众, $c < 0$ 表示第 $-c$ 台投票机, 满足 $1 <= c <= N$ 或 $1 <= -c < j$, 同一台机器的输入来源两两不同
- 每次修改满足 $1 <= i <= N$, $x in {0, 1}$, $1 <= y <= 10^9$
- 所有输入均为整数, 保证始终有解

=== Solution

首先这是一棵树

如果不带修, 这是一个比较平凡的 dp, 每个机器的结果只由最后一个投票者决定, 在此之前必须是平票, 这部分相当于 $n-1$ 个子节点全选 $0$, 然后选取 $w 1 - w 0$ 最小的 $(n-1)/2$ 个 作为代价, 使得 01 各半消耗最少, 最后一人控制结果 01

如果机器的结果取决于某个投票机, 那实际上也就取决于该子投票机的最后一个投票者, 所以相当于被子树内最后一个投票的人决定

这意味着每个投票人都决定了一条链的投票情况, 这部分信息可以直接处理出来

现在再考虑修改造成的影响, 一个人投票状况的修改其实对它控制的链的投票状况或者说 dp 过程没有影响, 它只影响了最后的附加权值, 但它会影响到它控制的链的上面一个节点, 也就是链顶的 dp 值会进入上方节点的前 $n-1$ 个信息中, 并可能影响到前 $(n-1)/2$ 的代价和, 这部分对答案也有额外的影响

所以修改本质上是一个树上单点的信息修改, 需要一个结构来维护每个节点的前 $(n-1)/2$ 小的权值之和, 我写了两个可删堆组成的对顶堆

=== Implementation
```cpp
#include "YRS/all.hpp"
#include "YRS/IO/fio.hpp"
#include "YRS/ttr/hld.hpp"
#include "YRS/ds/heap/erase_heap.hpp"

struct que {
  int n;
  ll s = 0;
  max_erase_heap<int> ls;
  min_erase_heap<int> rs;
  void build(var a) {
    n = si(a) / 2;
    for (int x : a) ls.eb(x), s += x;
    bina();
  }
  void bina() {
    while (si(ls) > n) {
      int x = ls.pop();
      rs.eb(x);
      s -= x;
    }
    while (si(ls) < n) {
      int x = rs.pop();
      ls.eb(x);
      s += x;
    }
  }
  void go(int x, int y) {
    if (y >= ls.top()) rs.eb(y);
    else ls.eb(y), s += y;
    if (x <= ls.top()) ls.pop(x), s -= x;
    else rs.pop(x);
    bina();
  }
};

void Yorisou() {
  INT(N, M, Q);
  vc<vc<int>> g(N + M);
  vc<PII> a(N);
  for (Z &[a, b] : a) IN(a, b);
  FOR(i, M) {
    INT(n);
    FOR(n) {
      INT(c);
      c = c > 0 ? c - 1 : -c - 1 + N;
      g[i + N].ep(c);
    }
  }
  hld v(g, N + M - 1, 1);
  var fa = v.fa;
  vc<int> cl(M + N, -1);

  FOR_R(i, N) {
    for (int x = i; x != -1 and cl[x] == -1; x = fa[x]) cl[x] = i;
  }

  vc<ll> f(N + M), dif(N + M);
  vc<que> q(N + M);
  FOR(i, N) {
    var [op, b] = a[i];
    if (op == 0) f[i] = 0, dif[i] = b;
    else f[i] = b, dif[i] = -b;
  }
  vc<int> buf;
  FOR(n, N, N + M) {
    buf.clear();
    for (int x : g[n]) if (cl[x] != cl[n]) buf.ep(dif[cl[x]]);
    q[n].build(buf);
    ll s = 0;
    for (int x : g[n]) s += f[x];
    s += q[n].s;
    f[n] = s;
  }
  vc<int> dis(N, N + M + 1), pos(N);
  FOR(n, N + M) {
    int c = cl[n];
    if (chmin(dis[c], v.d[n])) pos[c] = n;
  }
  ll s = f[N + M - 1];

  FOR(Q) {
    INT(i, x, y);
    --i;
    ll nf = x ? y : 0, ndf = x ? -y : y;
    int p = fa[pos[cl[i]]];
    if (p == -1) {
      s += nf - f[i];
    } else {
      s += nf - f[i] - q[p].s;
      q[p].go(dif[i], ndf);
      s += q[p].s;
    }
    f[i] = nf;
    dif[i] = ndf;
    print(min(s, s + dif[cl[N + M - 1]]));
  }
}

int main() { Yorisou(); }
```