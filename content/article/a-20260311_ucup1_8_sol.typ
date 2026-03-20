#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 1st Universal Cup. Stage 8: Slovenia",
  desc: [ucup 1-8 训练记录],
  date: "2026-03-11",
  tags: ("train", "tech", "sol", "rec", "icpc"),
)

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