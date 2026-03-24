#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Segment Tree Based on N-ary Tree",
  desc: [一个在一些场景下更快的类线段树实现],
  date: "2026-03-23",
  tags: ("alg", "ds"),
)

= Segment Tree Based on N-ary Tree

== Overview

基于多叉树的线段树实现, 在一些常见场景下比普通的线段树快, 实现简单

== Core Idea

=== Preliminaries

线段树可以基于多叉树, 想象一下四叉树的结构, 它比二叉树高度更低( $1 / 2$ ), 每一层更宽( $times 2$ ), 大概就是这样, 多叉树长得也都差不多, 这里就以四叉树为例说明

考虑最基本的线段树, 支持单点修改, 查询区间半群 prod , 当使用四叉树来维护区间信息时, 显然这样的结构因为高度只有一半, 单点修改相比二叉树只需要修改长度为一半的链, 而区间查询则需要用两倍的点来并出这个区间

上面这段内容是 well-known 的, 大家都知道当修改多, 查询少的时候用多叉树开实现线段树能更快, 或者说, "平衡一些复杂度", 不知道看完这段文字也知道了, 它很简单

=== Faster ?

但耗时的变化并不是简单的 $times 2$ 或 $\/ 2$ , 思考一下, 当使用普通的线段树维护最常见的加法群, 即单点加区间求和时, 时间都花在了哪里

加法运算, 也就是信息的合并是非常快速的, 单点修改需要修改不连续的 $log$ 个点, 区间求和则是要对不连续的 $log$ 个点的值求和, 这些过程实际上将时间花在了 *cache 不友好的访问*上

而对于一个 4 叉树, 区间查询时是这样的:

```cpp
X prod(int l, int r) {
  l += N, r += N;
  X s = unit();
  while (l / 4 != r / 4) {
    while (l & 3) s = op(s, a[l++]);
    while (r & 3) s = op(s, a[--r]);
    l /= B, r /= B;
  }
  FOR(i, l, r) s = op(s, a[i]);
  return s;
}
```
访问的层数还是一个更小的 log , 而多访问的一系列节点实际上是每层中连续编号的节点, 而*对连续节点的信息进行简单运算合并是非常快的*, 所以 4 叉树将单点修改变成了半个 log , 但没有将区间求和变成两个 log , 这同时也说明, 让树变"宽"的代价增长没有那么快

使用 Library Checker 的数据测试发现, 在 $N, Q = 2'000'00$ , $[0, 2^63)$ 级别的整数加法中, 使用 16 叉树跑得最快:
- 16_ary : 103 ms (max)
- 32_ary : 108 ms (max)
- 64_ary : 120 ms (max)
- standard seg tree : 144 ms (max)
- BIT : 97 ms (max)

可以看出在维护加法群时, 这种做法是比普通的线段树快一些的, 但比 BIT 慢, 它的优势在于可以维护不可逆的信息, BIT 要求信息可逆来求差分, 在修改多查询少的情景下也比 BIT 快

由于是在 BJTU OJ 上进行的测试, 会比主流 OJ 慢一些

== Implementation

采用了类非递归线段树的结构实现, 同时为了防止建立满 $N$ 叉树浪费巨量空节点的空间, 只开了 $2N$ 个节点用类非递归的方式建树, 这样建出来的会有点歪, 也不能保证信息有序合并, 也就是需要交换律, 要保证有序可能必须要建满的树. 这个方法在二叉的线段树中也可以用来省空间

这样实现的好处显而易见, 很短很简单, 和普通的非递归线段树很像, 大体上就是将一些 if 改成了 while

将 B 设为 2 的幂次能让下标计算中的除法更快一点

```cpp
template <typename T, uint B = 1 << 5>
  requires(T::commute)
struct range_sum_point_add : T {
  using X = T::X;
  using T::op, T::unit;
  int N;
  vc<X> a;

  range_sum_point_add(const vc<X> &a) { build(a); }

  void build(const vc<X> &c) {
    N = si(c);
    a.assign(N << 1, unit());
    FOR(i, N) a[i + N] = c[i];
    FOR_R(i, 1, N << 1) a[i / B] = op(a[i / B], a[i]);
  }

  void multiply(int i, X x) {
    i += N;
    a[i] = op(a[i], x);
    while (i /= B) a[i] = op(a[i], x);
  }

  X prod(int l, int r) {
    l += N, r += N;
    X s = unit();
    while (l / B != r / B) {
      while (l & (B - 1)) s = op(s, a[l++]);
      while (r & (B - 1)) s = op(s, a[--r]);
      l /= B, r /= B;
    }
    FOR(i, l, r) s = op(s, a[i]);
    return s;
  }
};
```