#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "关于我",
  desc: [一点自我介绍],
  date: "2025-10-20",
  tags: (),
  show-outline: false,
)

= Yorisou

// #figure(image("/public/trash.svg", alt: "yorisou"), caption: "yorisou")
#image("/public/trash.svg", alt: "yorisou")

= 关于博客

主要是记录个人学习，以及一些乱七八糟的东西

= 阿巴阿巴
在这里放一棵线段树
```cpp
template <typename monoid>
struct Seg {
  using MX = monoid;
  using X = MX::X;

  vector<X> dat;
  int N, log, sz;

  Seg(int N = 0) { build(N, [](int i) { return MX::unit(); }); }
  template <typename F>
  Seg(int N, F f) { build(N, f); }
  Seg(const vector<X> &v) { build(len(v), [&](int i) { return v[i]; }); }

  template <typename F>
  void build(int M, F f) {
    N = M, log = 1;
    while ((1 << log) < N) ++log;
    sz = 1 << log;
    dat.assign(sz << 1, MX::unit());
    FOR(i, N) dat[sz + i] = f(i);
    FOR_R(i, 1, sz) update(i);
  }

  void update(int i) { dat[i] = MX::op(dat[i << 1], dat[i << 1 | 1]); }

  X get(int i) { return dat[sz + i]; }

  void set(int i, const X &x) {
    dat[i += sz] = x;
    while (i >>= 1) update(i);
  }
  void multiply(int i, const X &x) {
    i += sz;
    dat[i] = MX::op(dat[i], x);
    while (i >>= 1) update(i);
  }

  X prod(int l, int r) {
    X x = MX::unit(), y = MX::unit();
    l += sz, r += sz;
    while (l < r) {
      if (l & 1) x = MX::op(x, dat[l++]);
      if (r & 1) y = MX::op(dat[--r], y);
      l >>= 1, r >>= 1;
    }
    return MX::op(x, y);
  }
};
```
