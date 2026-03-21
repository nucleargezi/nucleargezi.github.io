#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Radix Heap",
  desc: [一个快速的堆实现],
  date: "2026-03-21",
  tags: ("alg", "ds"),
)

= Radix Heap

== Overview

一个更快的堆实现, 但具有一定限制: key 只能是整数, 而且插入的 key 不能小于已经被弹出的 key , 也就是 pop 的 key 单调不降

典型的使用场景就是用来替代 dij 最短路中的优先队列, 在 luogu 的单源最短路模板题上大约快了 $40%$

== Core Idea

原理可能也不是很重要, 知道限制条件需要的时候抄来用就行(

有一个 last 变量用于标记被弹出的最后一个 key , vs[] 是 bit 个桶, ms[] 存每个桶的最小元素

=== Push(key, val)

一个 key 如果和 last 的最高不同位是第 i 位的话, 就放在 vs[i + 1] 中, 相同全放 vs[0] 

这是一个简单的二进制分组, 桶编号越小, 桶中元素与 last 的差距越小

=== Pop()

当弹出元素时, 如果 vs[0] 中有元素, 说明存在与 last 相同的元素, 直接弹出

如果 vs[0] 非空, 则向后一位一位找到第一个非空桶 vs[i] , 将 ms[i] 设置为 last , 并重新放置 vs[i] 中的元素, 显然这些元素与新 last 的不同 topbit 一定在 i 前面, 他们被重新分配进前面的桶中, ms[i] 则被扔进了 vs[0]

这里也能说明其复杂度, 每个 key 最多只会被移动到前面的桶 bit 次, 也就是 $log(V)$

== Implementation

```cpp
template <typename ke, typename val>
  requires(is_integral_v<ke>)
struct fheap {
  using uint = typename make_unsigned<ke>::type;
  static constexpr int bit = sizeof(ke) << 3;
  vc<pair<uint, val>> vs[bit + 1];
  uint ms[bit + 1];

  int s;
  uint la;

  fheap() : s(0), la(0) { fill(ms, ms + bit + 1, uint(-1)); }

  void emplace(uint k, val w) {
    ++s;
    int i = topbit(k ^ la) + 1;
    vs[i].ep(k, w);
    chmin(ms[i], k);
  }

  pair<uint, val> pop() {
    if (ms[0] == uint(-1)) {
      int i = 1;
      while (ms[i] == uint(-1)) ++i;
      la = ms[i];
      for (Z &x : vs[i]) {
        int i = topbit(x.fi ^ la) + 1;
        vs[i].ep(x);
        chmin(ms[i], x.fi);
      }
      vs[i].clear();
      ms[i] = uint(-1);
    }
    --s;
    Z s = ::pop(vs[0]);
    if (vs[0].empty()) ms[0] = uint(-1);
    return s;
  }
  
  bool empty() const { return s == 0; }

  int size() const { return s; }
};
```