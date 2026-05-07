#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record The 3rd Universal Cup. Stage 31: Wroclaw",
  desc: [ucup 3-31 训练记录],
  date: "2026-05-01",
  tags: ("icpc",),
  category: "ICPC",
)

= The 3rd Universal Cup. Stage 31: Wroclaw 

#link("https://qoj.ac/contest/1924", "Qoj Link") 

== Hitokoto

新赛季组队训练开始

== C. CERC Plaques
- In-Contest Solves: 250/334 (ucup)
- #link("https://qoj.ac/contest/1924/problem/10116")

=== Formal Problem Statement

给定 $N$ 个互不相同的名字 $S_1,S_2,dots,S_N$, 以及 $N$ 个互不相同的牌子昵称 $T_1,T_2,dots,T_N$. 

若字符串 $T$ 的前四个字符与字符串 $S$ 的前四个字符完全相同, 则称昵称 $T$ 可以分配给名字 $S$. 大小写字母视为不同字符. 

请判断是否存在一个排列 $p$, 使得对所有 $1 <= i <= N$, 昵称 $T_{p_i}$ 都可以分配给名字 $S_i$. 

若不存在这样的分配, 输出 `NO`.   
若存在, 输出 `YES`, 并输出任意一种合法分配方案

=== Solution

签到题, 若存在合法方案, 将两组字符串排序后一一对应的方案一定是合法方案之一

=== Implementation

```cpp
void Yorisou() {
  INT(N);
  VEC(string, a, N);
  VEC(string, b,N);
  sort(a);
  sort(b);
  FOR(i, N) if (a[i].substr(0, 4) != b[i].substr(0, 4)) return print("NO");
  print("YES");
  FOR(i, N) print(a[i], b[i]);
}
```

== E. Expression
- In-Contest Solves: 44/165 (ucup)
- #link("https://qoj.ac/contest/1924/problem/10118")

=== Formal Problem Statement

给定一个表达式 $E$. 表达式中只会出现变量 `a` 到 `j`, 以及二元运算符 `min`、`max`、`<=`、`<`. 

表达式满足如下文法：

- `var := a | b | ... | j`
- `op := expr <= expr | expr < expr | min expr expr | max expr expr`
- `expr := var | (op)`

每个变量的取值均为 $0$ 或 $1$. 运算符 `min`、`max` 表示普通的最小值与最大值, 运算符 `<`、`<=` 表示比较运算, 其结果也为 $0$ 或 $1$. 

两个表达式 $A, B$ 被称为等价, 当且仅当：

+ $A$ 与 $B$ 中出现的变量集合完全相同；
+ 对这个变量集合的任意 $0/1$ 赋值, $A$ 与 $B$ 的计算结果都相同. 

请判断是否存在一个只使用变量以及二元运算符 `min` 和 `<=` 的表达式 $F$, 使得 $F$ 与输入表达式 $E$ 等价. 

若不存在, 输出 `NO`. 

若存在, 输出 `YES`, 并输出任意一个满足条件的表达式 $F$. 要求 $F$ 中的二元运算次数不超过 $40000$. 

=== Constraints

- 输入表达式中二元运算次数不超过 $200$. 
- 变量只可能是 `a` 到 `j`. 
- 若存在任意大小的合法表达式, 则一定存在一个二元运算次数不超过 $40000$ 的合法表达式. 

=== Solution

构思题, 要写表达式解析和求值

=== Implementation
```cpp
enum op { max, min, less_eq, less, val, l, r };
struct dat {
  op t;
  int x;
};

struct DS {
  vc<dat> exp, val;
  set<int> vr;
  vc<int> a;
  vc<PII> v;

  DS(string s) {
    int n = si(s);
    FOR(i, n) if (s[i] != ' ') {
      if (s[i] == '(') exp.ep(dat{op::l, 0});
      else if (s[i] == ')') exp.ep(dat{op::r, 0});
      else if (s[i] == 'm') {
        if (s[i + 1] == 'a') exp.ep(dat{op::max, 0});
        else exp.ep(dat{op::min, 0});
        i += 2;
      } else if (s[i] == '<') {
        if (i + 1 < n and s[i + 1] == '=') {
          exp.ep(dat{op::less_eq, 0});
          ++i;
        } else {
          exp.ep(dat{op::less, 0});
        }
      } else {
        exp.ep(dat{op::val, s[i] - 'a'});
        vr.eb(s[i] - 'a');
      }
    }

    int tot = 0;
    Z f = [&](Z &f, int l, int r) -> int {
      int id = tot++;
      v.ep();
      val.ep();
      if (r - l == 1) {
        v[id] = {-1, -1};
        val[id] = exp[l];
        return id;
      }
      ++l, --r;
      if (exp[l].t == op::max or exp[l].t == op::min) {
        int sm = 0;
        val[id] = exp[l];
        FOR(i, l + 1, r) {
          if (exp[i].t == op::l) sm += 1;
          if (exp[i].t == op::r) sm -= 1;
          if (sm == 0) {
            v[id].fi = f(f, l + 1, i + 1);
            v[id].se = f(f, i + 1, r);
            break;
          }
        }
      } else {
        int sm = 0;
        FOR(i, l, r) {
          if (exp[i].t == op::l) sm += 1;
          if (exp[i].t == op::r) sm -= 1;
          if (sm == 0) {
            val[id] = exp[i + 1];
            v[id].fi = f(f, l, i + 1);
            v[id].se = f(f, i + 2, r);
            break;
          }
        }
      }
      return id;
    };
    f(f, 0, si(exp));
    a = vc<int>(all(vr));
  }

  int eval(string s) {
    int sz = si(a);
    map<int, int> mp;
    FOR(i, sz) if (s[i] == '1') mp[a[i]] = 1;
    Z f = [&](Z &f, int i) -> int {
      if (v[i] == PII{-1, -1}) return mp[val[i].x];
      else if (val[i].t == op::min) return std::min(f(f, v[i].fi), f(f, v[i].se));
      else if (val[i].t == op::max) return std::max(f(f, v[i].fi), f(f, v[i].se));
      else if (val[i].t == op::less) return f(f, v[i].fi) < f(f, v[i].se);
      else return f(f, v[i].fi) <= f(f, v[i].se);
    };
    return f(f, 0);
  }
};

string make(vc<string> a) {
  if (si(a) == 1) return a[0];
  deque<string> q;
  q.ep("(min " + a[0] + " " + a[1] + ")");
  FOR(i, 2, si(a)) {
    q.emplace_front("(min ");
    q.ep(" " + a[i] + ")");
  }
  string s;
  for (string &t : q) s += t;
  return s;
}

string gen_one(const vc<int> &g) {
  vc<string> go;
  for (int x : g) go.ep(string{char(x + 'a')});
  return make(go);
}

string gen_zero(const vc<int> &l) {
  vc<string> go;
  FOR(i, si(l)) {
    int nx = (i + 1) % si(l);
    string f = "(";
    f += char(l[i] + 'a');
    f += " <= ";
    f += char(l[nx] + 'a');
    f += ")";
    go.ep(f);
  }
  return make(go);
}

void Yorisou() {
  string s;
  getline(cin, s);
  DS f(s);
  int sz = si(f.a);
  string msk(sz, '0');
  vc<int> dp(1 << sz);
  FOR(s, 1 << sz) {
    FOR(i, sz) msk[i] = '0' + (s >> i & 1);
    dp[s] = f.eval(msk);
  }
  if (dp.back() != 1) return NO();
  if (sz == 1) {
    YES();
    if (dp[0] == 0) print(s);
    else print("(" + s + " <= " + s  + ")");
    return;
  }
  vc<string> str;
  vc<int> l, r;
  FOR(s, 1 << sz) if (dp[s] == 1) {
    l.clear(), r.clear();
    FOR(i, sz)((s >> i & 1) ? r : l).ep(i);
    if (si(l) <= 1) {
      vc<int> g(r);
      for (int &x : g) x = f.a[x];
      str.ep(gen_one(g));
    } else {
      vc<int> g(l);
      for (int &x : g) x = f.a[x];
      string tmp = gen_zero(g);
      if (si(r) == 0) {
        str.ep(tmp);
      } else {
        g = r;
        for (int &x : g) x = f.a[x];
        str.ep("(min " + tmp + ' ' + gen_one(g) + ")");
      }
    }
  }
  YES();
  string ans;
  if (si(str) == 1) {
    ans = str[0];
  } else {
    string s = str[0];
    int sz = si(str), c = (sz - 1) << 1;
    FOR(i, 1, sz) s += " <= " + str[i] + ')' + " <= " + str[i] + ')';
    ans = string(c, '(') + s;
  }
  print(ans);
}
```

== F. Flats
- In-Contest Solves: 103/410 (ucup)
- #link("https://qoj.ac/contest/1924/problem/10119")

=== Formal Problem Statement

给定 $N$ 块砖, 按输入顺序依次投入一条无限长、底部初始水平的沟中. 问题可视为二维平面中的过程. 

第 $i$ 块砖由三个整数 $l_i, r_i, h_i$ 描述, 表示它在水平方向覆盖区间 $[l_i, r_i]$, 高度为 $h_i$. 砖在下落过程中保持方向不变, 只会竖直向下移动, 直到碰到沟底或之前已经停止的砖. 仅有边界或侧面的接触不会阻止砖继续下落. 

所有砖停止后, 若某个非零面积的空白区域被砖或沟壁完全围住, 则称其为一个公寓. 若两个空白区域之间无法通过正面积的通道连通, 则它们被视为不同的公寓；仅在角点接触的区域也视为不同. 

请计算所有砖下落完成后形成的公寓数量. 

=== Constraints

- $1 <= N <= 200000$
- $0 <= l_i < r_i <= 200000$
- $1 <= h_i <= 10^9$

=== Solution

这题只要求被围住的连通块数量, 其实面积也是能求的

模拟整个过程, 连通块会在两种情况下产生, 一种是一个方块落下后对某个连通块完成了"封顶", 另一种是落下后填补了侧面空档, 在模拟中同时处理这两种情况会加大代码实现难度

考虑后一种情况的方块状态, 如果改变该方块下落的次序, 让它早点下落, 使得最后下落的是顶部方块, 这样并不会改变方块堆叠的结果, 但能避免讨论这种麻烦的情况, 所以进行这样的处理: *先模拟一遍方块下落, 统计每个方块下落后底边的高度, 以此为序再次模拟整个过程*, 此时连通块只会在"封顶"时产生, 可以很简单地统计

模拟过程使用珂朵莉树, 可以很方便地进行区间覆盖, 在覆盖时统计这部分区间因封顶产生的连通块

=== Implementation
```cpp
using DS = chtholly<ll>;
using X = DS::X;
void Yorisou() {
  INT(N);
  DS seg(-1);
  seg.set(-1, 2'000'001, 0);
  VEC(T3<int>, a, N);
  vc<ll> h;
  for (var [l, r, x] : a) {
    ll f = 0;
    for (var [l, r, x] : seg.get(l, r)) chmax(f, x);
    h.ep(f);
    f += x;
    seg.set(l, r, f);
  }
  seg.set(-1, 2'000'001, 0);
  int s = 0;
  for (int i : argsort(h)) {
    var [l, r, d] = a[i];
    ll hi = h[i];
    bool ls = seg.get(l - 1).x >= hi, rs = seg.get(r).x >= hi;
    vc<X> a = seg.get(l, r), b;
    int sz = si(a);
    FOR(i, sz) {
      if (i and a[i].x != hi and a[i - 1].x != hi) continue;
      b.ep(a[i]);
    }
    sz = si(b);
    if (sz != 1) FOR(i, sz) {
      var [l, r, x] = b[i];
      if (i == 0) {
        if (ls and hi != x) ++s;
      } else if (i == sz - 1) {
        if (rs and hi != x) ++s;
      } else if (hi != x) ++s;
    }
    seg.set(l, r, hi + d);
  }
  print(s);
}
```

== 
- In-Contest Solves: 223/354 (ucup)
- #link("https://qoj.ac/contest/1924/problem/10125")

=== Formal Problem Statement

== Formal Problem Statement

给定一个 $N times N$ 的迷宫, 每个格子要么是通道 `.`, 要么是墙 `#`. 棋子位于某个通道格子中, 并面朝四个方向之一：上、下、左、右. 

对于一次移动, 棋子按照如下策略行动：

设棋子当前面朝方向为 $d$. 依次检查相对于 $d$ 的右方、前方、左方、后方四个方向, 选择第一个满足如下条件的方向：

- 朝该方向走一步不会进入墙；
- 若该方向走一步会离开迷宫, 则也视为可以选择. 

棋子随后转向该方向并走一步. 若这一步离开了迷宫, 则过程结束, 认为棋子成功走出迷宫. 

给定 $Q$ 个询问, 每个询问给出棋子的初始位置 $(r,c)$ 和初始朝向 $d$. 请对每个询问判断棋子是否会最终离开迷宫, 并输出离开迷宫所需的移动次数；若永远不会离开, 则输出 $-1$. 

=== Constraints

- $1 <= N <= 1000$
- $1 <= Q <= 100000$
- $1 <= r,c <= N$
- $d in {`U`, `D`, `L`, `R`}$

=== Solution

倒着 bfs 预处理所有答案

=== Implementation
```cpp
void Yorisou() {
  static constexpr int dx[]{0, -1, 0, 1}, dy[]{1, 0, -1, 0};
  INT(N, Q);
  VEC(string, s, N);
  FOR(i, N) FOR(k, N) s[i][k] = s[i][k] == '.';
  retsu<array<int, 4>> rs(N, N, {-1, -1, -1, -1});
  retsu<array<bool, 4>> vis(N, N);
  queue<T3<int>> q(N * N);
  FOR(i, N) FOR(k, N) if (s[i][k]) {
    if (min(i, k) == 0 or max(i, k) == N - 1) {
      FOR(d, 4) FOR(g, -1, 3) {
        int t = (d + g + 4) & 3, x = i + dx[t], y = k + dy[t];
        if (min(x, y) < 0 or max(x, y) >= N) {
          q.eb(i, k, d);
          rs[i][k][d] = 1;
          vis[i][k][d] = 1;
        } else if (s[x][y]) break;
      }
    }
  }

  while (not q.empty()) {
    Z [x, y, rd] = pop(q);
    FOR(g, 4) {
      int xx = x + dx[g], yy = y + dy[g];
      if (min(xx, yy) >= 0 and max(xx, yy) < N and s[xx][yy]) {
        FOR(d, 4) if (not vis[xx][yy][d]) FOR(dd, -1, 3) {
          int t = (d + dd + 4) & 3, gx = xx + dx[t], gy = yy + dy[t];
          if (min(gx, gy) >= 0 and max(gx, gy) < N and s[gx][gy]) {
            if (gx == x and gy == y and t == rd) {
              rs[xx][yy][d] = rs[x][y][t] + 1;
              q.eb(xx, yy, d);
              vis[xx][yy][d] = 1;
            }
            break;
          }
        }
      }
    }
  }

  FOR(Q) {
    INT(x, y);
    CH(c);
    --x, --y;
    FOR(i, 4) if (c == "RULD"[i]) print(rs[x][y][i]);
  }
}
```

// == 
// - In-Contest Solves:  (ucup)
// - #link(" ")

// === Formal Problem Statement

// === Solution

// === Implementation
// ```cpp

// ```