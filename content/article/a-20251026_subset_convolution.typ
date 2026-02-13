#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Subset Convolution 模板",
  desc: [魔怔卡常短码量子集卷积],
  date: "2080-10-25",
  tags: (
    blog-tags.alg,
    blog-tags.temp,
    blog-tags.tech,
  ),
  show-outline: true,
)

#set text(size: 8pt)
= Subset Convolution Template
== 这是一份子集卷积模板
给定两个长度为 $2^n$ 的序列 $a_0 , a_1 , dots.h.c , a_(2^n - 1)$ 和
$b_0 , b_1 , dots.h.c , b_(2^n - 1)$，你需要求出一个序列
$c_0 , c_1 , dots.h.c , c_(2^n - 1)$，其中 $c_k$ 满足：

$ c_k = sum_(i amp j = 0\
i med divides med j = k) a_i b_j $

#zebraw(
  numbering: true,
  ```cpp
  #define ad(a, b) if ((a += b) >= mod) a -= mod
  #define sb(a, b) if ((a -= b) < 0) a += mod

  constexpr int mod = 1'000'000'000 + 9;

  vector<int> f(const vector<int> &a, const vector<int> &b) {
    int N = len(a), n = topbit(N);
    vector<array<int, 20>> x(N), y(N);
    FOR(i, N - 1) x[i][pc(i)] = a[i];
    FOR(k, n) FOR(i, N) if (~i >> k & 1) FOR(j, pc(i) + 1)
      ad(x[i | 1 << k][j], x[i][j]);
    FOR(i, N - 1) y[i][pc(i)] = b[i];
    FOR(k, n) FOR(i, N) if (~i >> k & 1) FOR(j, pc(i) + 1)
      ad(y[i | 1 << k][j], y[i][j]);

    FOR(i, N) {
      FOR(j, pc(i) + 1) FOR(k, pc(i) + 1 - j, min(pc(i), n - 1 - j) + 1)
        ad(x[i][j + k], 1ll * x[i][j] * y[i][k] % mod);
      ll s = 0;
      FOR(j, pc(i) + 1) s += 1ll * x[i][j] * y[i][pc(i) - j];
      x[i][pc(i)] = s % mod;
    }
    FOR(k, n) FOR(i, N) if (~i >> k & 1) FOR(j, pc(i), n) 
      sb(x[i | 1 << k][j], x[i][j]);
    vector<int> r(N);
    FOR(i, N - 1) r[i] = x[i][pc(i)];
    FOR(i, N) ad(r[N - 1], 1ll * a[i] * b[N - 1 - i] % mod);
    return r;
  }
  ```
)
#pagebreak()
== 这是另一份子集卷积模板
线下赛时我们可能需要一份简短的模板，有时也会遇到卡常的需求，如果不用 simd 之类的魔怔东西，这是最快的子集卷积模板，码量较小，个人使用时由于本来就要带一些宏，实际码量会更小一些。

当然我更希望区域赛不要出这种东西。
#zebraw(
  numbering: true,
  ```cpp
  #define F(a) for (int i = 0; i < (a); ++i)
  #define FF(i, a) for (int i = 0; i < (a); ++i)
  #define FFF(i, a, b) for (int i = (a); i < (b); ++i)
  #define OV(a, b, c, d, ...) d
  #define FOR(...) OV(__VA_ARGS__, FFF, FF, F)(__VA_ARGS__)

  #define p std::__popcount(uint(i))
  #define t i | 1 << k
  #define FL FOR(k, n) FOR(i, N) if (~i >> k & 1)
  #define ADD FOR(k, p - j, min(p, n - 1 - j) + 1) c[j + k] += ull(x[i][j]) * y[i][k]
  #define ad(a, b) if ((a += b) >= mod) a -= mod
  #define sb(a, b) if ((a -= b) < 0) a += mod

  constexpr int mod = 1'000'000'000 + 9;

  vector<int> f(const vector<int> &a, const vector<int> &b) {
    const int N = a.size(), n = 31 - __builtin_clz(N);
    vector<array<int, 20>> x(N), y(N);
    FOR(i, N - 1) x[i][p] = a[i];
    FL FOR(j, p + 1) ad(x[t][j], x[i][j]);
    FOR(i, N - 1) y[i][p] = b[i];
    FL FOR(j, p + 1) ad(y[t][j], y[i][j]);

    const int D = 16;
    ull c[20]{};
    FOR(i, N) {
      int LM = min(p * 2, n - 1) + 1;
      FOR(j, p, LM) c[j] = 0;
      if (p + 1 <= D) {
        FOR(j, p + 1) ADD;
      } else {
        FOR(j, D) ADD;
        FOR(j, p, LM) c[j] %= mod;
        FOR(j, D, p + 1) ADD;
      }
      FOR(j, p, LM) x[i][j] = c[j] % mod;
    }
    FL FOR(j, p, n) sb(x[t][j], x[i][j]);
    vector<int> r(N);
    FOR(i, N - 1) r[i] = x[i][p];
    FOR(i, N) r[N - 1] = (r[N - 1] + ull(a[i]) * b[N - i - 1]) % mod;
    return r;
  }
  #undef t
  ```
)