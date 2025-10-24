#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Record UCUP 3-30: Northern",
  desc: [UCUP 3-30 部分题解],
  date: "2025-10-23",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.sol,
  ),
  show-outline: false,
)

= The 3rd Universal Cup. Stage 30: Northern
== A.Archaeology
=== 简要题意
在一个 $N * N$ （$N<=10^9$）的空间内 有一个随机的特殊整点，需要找到它，每次可以询问一个整点 $O$ ，得到空间中射线 $arrow(O A)$ 所在的半平面内的随机一个点，在90次询问中找出这个点，询问和回答为同一个点即为找到。
=== Solution
对于点可能在的范围，将其看作一个凸多边形，由于每次询问可以得到一个半平面的限制，每次询问重心可以将可选范围切割掉一半，这似乎是一个很好想到的解决方案，操作次数也绰绰有余（可以看作在 $x, y$ 两个维度的二分，操作最劣应该是 $30+30$ 次）。

我并不打算卖关子，这种做法在一些情况，比如多边形变成 边长为2的矩形 时会出问题，在 $N==2$ 的 case 就会直接挂掉，由于询问和回答的是整点，这时询问的重心会是一个角，无论回答的是哪个角，直接切割后得到的新凸多边形会和原来的一样，于是会不断询问同一个点。

解决方法很简单，可以让重心向周围四个方向随机偏移一下：
#zebraw(
  ```cpp
  constexpr RE eps = 0.3;

  P s = polygon.center();
  ll x = std::llround(s.x + (rng() & 1 ? eps : -eps)),
     y = std::llround(s.y + (rng() & 1 ? eps : -eps));
  ```,
)

可能在多边形小的时候暴力询问所有点也可以，不过我没有尝试。

这样会让操作次数变多一点，但 $90$ 次操作足够了。

=== Tech
- 多边形的重心
这题需要求多边形的重心，一个简单求法是将多边形拆成 $N-2$ 个三角形，然后由三角形的重心（同时也是中心）以面积加权平均得来。
#zebraw(
  ```cpp
  P center() const {
    if (N == 1) return ps[0];
    if (N == 2) return (ps[0] + ps[1]) / 2;

    T s = 0;
    P p(0, 0), O = ps[0];
    FOR(i, 1, N - 1) {
      P x = ps[i] - O, y = ps[i + 1] - O;
      T ar = x.det(y);
      s += ar;
      p += (O + ps[i] + ps[i + 1]) * ar;
    }
    return p / 3 / s;
  }
  ```
)
- convex cut
另一个需要的操作是用一条直线分割凸多边形，可以对着凸包扫一遍，将在直线一侧的点和与直线相交的点取出来。
#zebraw(
  ```cpp
  vector<P> convex_cut(P s, P t) const {
    vector<P> res;
    line l(s, t);
    for (int i = 0; i < N; ++i) {
      P p1 = ps[i], p2 = ps[nxt(i)];
      bool p1_ins = ccw(s, p1, t) != 1;
      bool p2_ins = ccw(s, p2, t) != 1;
      if (p1_ins) 
        res.emplace_back(p1);
      if (p1_ins != p2_ins)
        res.emplace_back(l.cross_point(line(p1, p2)).second);
    }
    return res;
  }
  ```
)