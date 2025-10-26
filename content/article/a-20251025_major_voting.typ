#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Major Voting 但是 1/5",
  desc: [关于多数投票的一点笔记],
  date: "2025-10-25",
  tags: (
    blog-tags.alg,
    blog-tags.tech
  ),
  show-outline: false,
)

#set text(size: 8pt)

= Major Voting
== 严格区间众数
=== Introduction
一个序列中出现次数超过序列长度一半的数
=== Problem
考虑这样一个问题：给一个序列，每次询问查询 $[L, R)$ 范围内的严格区间众数，保证 $[L, R)$ 范围内有这样的数
=== Solution
每次删除两个不同的数，最后剩下的就是绝对众数，可以维护这样一个信息 {number, cnt} 来表示区间内可能的众数和它“剩余的”出现的次数，两个区间信息合并时，如果数字一样就累加 cnt ，否则返回出现次数多的数字，并将它的剩余次数减去少的那个：
#zebraw(
  ```cpp
  using X = pair<int, int>;
  
  X op(X L, X R) {
    if (L.first == R.first) return {L.first, L.second + R.second};
    int d = min(L.second, R.second);
    L.second -= d, R.second -= d;
    return L.second > R.second ? L : R;
  }
  ```
)
这个信息性质优良，满足结合率，使用线段树等结构来维护它，就可以解决这个问题
=== 问题的延伸
上面的问题保证了答案存在，如果不保证，就需要维护一个额外的结构来检测查到的数字是否为真正的绝对众数

对于静态的问题，有个简单的做法是将每种数字的出现位置用一个 std::vector 分别储存，查询时二分出左右边界相减得到总的次数。

如果需要单点修改，可以对每个数字开一颗动态开点线段树，修改时在原数的树上删一个点，在新数的树上加一个点，实现比较简单，这个子问题还有空间 $O(N)$ 时间 $O(log(N))$ 的在线做法，有兴趣的读者自己研究。

如果需要区间推平，仍然可以对每个数字开一颗动态开点线段树，修改时可以在原序列的线段树上二分查找范围内的若干连续段推平，同时在动态开点线段树上区间修改，也可以维护一棵珂朵莉数来查找和修改连续段。

Link: #link("https://judge.yosupo.jp/problem/majority_voting", "单点修改区间绝对众数查询模板题")

== 不严格的区间众数
=== Problem
下面看这样一道题：#link("https://codeforces.com/contest/643/problem/G", "CF643G Choosing Ads")

给定一个长度为 $N$ 的序列， $Q$ 次询问和 $P$ ($1<=N,Q<=2*10^5$，$20<=P<=100$)，支持以下操作：
- 将 $[L, R)$ 内的数修改为 $x$
- 查询 $[L, R)$ 范围内出现次数超过 $P%$ 的数字，要求输出一个集合，包含全部符合条件的数字，可以输出多余的数字。
=== Solution
这题区间内可能有 $S = floor(N / P)$ ($1<=S<=5$) 个答案，所以可以每次删除 $S$ 个不同的数，具体的信息合并可以这样：
#zebraw(
  ```cpp
  using X = array<piar<int, int>, 5>;

  void f(X &L, piar<int, int> x) {
    if (x.first == -1) return;
    FOR(i, S) if (L[i].first == x.first) return L[i].second += x.second, void();
    FOR(i, S) if (L[i].first == -1) return L[i] = x, void();
    int d = x.second;
    FOR(i, S) if (L[i].first != -1) chmin(d, L[i].second);
    x.second -= d;
    FOR(i, S) if ((L[i].second -= d) <= 0) L[i] = {-1, 0};
    if (x.second > 0) FOR(i, S) if (L[i].first == -1) return L[i] = x, void();
  }
  X op(X L, X R) {
    FOR(i, S) f(L, R[i]);
    return L;
  }

  X get(int x) {
    X r{};
    r.fill({-1, 0});
    r[0] = {x, 1};
    return r;
  }
  ```
)