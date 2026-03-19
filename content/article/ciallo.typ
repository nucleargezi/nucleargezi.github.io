#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Ciallo World",
  desc: [testtest],
  date: "2026-03-18",
  tags: ("hello", "typst"),
)

= Hello
这是正文内容。行内公式示例：$a^2 + b^2 = c^2$。

test

じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。

じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。じゃんけんの結果を標準出力に出力してください。

== 2

阿巴阿巴

test

=== 3
阿巴阿巴

阿巴阿巴

阿巴阿巴


test
==== 4
阿巴阿巴

test
===== 5
阿巴阿巴

test
== Code Example

阿巴阿巴 ``` print("Ciallo") ```

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
