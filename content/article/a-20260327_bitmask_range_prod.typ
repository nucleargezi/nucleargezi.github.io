#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Bitmask Range Prod",
  desc: [静态序列的子集 prod 查询],
  date: "2026-03-25",
  tags: ("alg", "ds"),
)

= Bitmask Range Prod

== Overview

一种处理次询问静态序列子集 prod 的结构

具体而言, 它用于解决这样的问题, 给定一个长度 $N$ 的静态序列, 维护任意幺半群, 比如整数加法, 查询时给一个 bitset 和一个区间 $[L, R)$ , 查询序列 $[L, R]$ 范围内 bit[i] 为 1 的位置的所有元素的 prod

省流 预处理 时间 $O(192N)$ 空间 $O(200N)$ 单次查询 $O((r - l) / 10)$

在大量查询时会有一定优势, 但不知道什么题能快速给子集, 猜测可能用于, 多次单点修改 bitset 且元素不可逆的情况, 或者多个 bitset 不断互相进行位运算生成 bitmask 的情况

== Core Idea

=== Build()

对于每连续 64 位, 也就是 bitset 中的一个 ull , 分出一个块, 每块再拆成 6 个块, 其中前 5 个块含有 11 个元素, 后一个块放 9 位有效元素和两个单位元, 每段处理出一个 $2^11$ 大小的表, 处理出连续 11 位所有 bitmask 的表, 这部分可以状压 dp 或者类似的处理解决

=== Prod()

查询时对于大小不到 64 的两段散块暴力求积, 对于连续 64 位的整块, 查 6 次表, 在一些 oj 上可能还要手动循环展开来加速

== Implementation

经测试 $10^5*10^5$ 范围的 ull 加法群可以在 1s (or 2s ?) 内跑完, 但我忘记当时是怎么测的了, 可能实际上会更快一点(

```cpp
TE struct range_bitmsk_prod : T {
  using X = T::X;
  using T::unit, T::op;
  int N;
  vc<X> a;
  vc<array<X, 1 << 11>> f;
  
  range_bitmsk_prod(const vc<X> &a) : N(si(a)), a(a), f(N / 64 * 6 + 10) {
    int bsz = (N + 63) >> 6;
    FOR(bi, bsz) FOR(k, 6) {
      int b = 6 * bi + k;
      f[b].fill(unit());
      FOR(i, 11) {
        int id = 64 * bi + 11 * k + i;
        X x = unit();
        if ((k < 5 or i < 9) and id < N) x = a[id];
        FOR(s, 1 << i) f[b][1 << i | s] = op(f[b][s], x);
      }
    }
  }
  
  X prod(const bs &bit, int l, int r) {
    assert(l <= r);
    assert(r <= bit.N);
    X ls = unit(), rs = ls;
    while (l < r and (l & 63)) {
      if (bit[l]) ls = op(ls, a[l]);
      ++l;
    }
    while (l < r and (r & 63)) {
      --r;
      if (bit[r]) rs = op(a[r], rs);
    }
    if (l == r) return op(ls, rs);
    l >>= 6, r >>= 6;
    FOR(i, l, r) {
      ull s = bit.a[i];
      ls = op(ls, f[i * 6 + 0][s >> (0 * 11) & 2047]);
      ls = op(ls, f[i * 6 + 1][s >> (1 * 11) & 2047]);
      ls = op(ls, f[i * 6 + 2][s >> (2 * 11) & 2047]);
      ls = op(ls, f[i * 6 + 3][s >> (3 * 11) & 2047]);
      ls = op(ls, f[i * 6 + 4][s >> (4 * 11) & 2047]);
      ls = op(ls, f[i * 6 + 5][s >> (5 * 11) & 2047]);
    }
    return op(ls, rs);
  }
};
```