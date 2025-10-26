#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "NTT convolution",
  desc: [一份简短的 NTT 卷积模板，以及三模 NTT （任意模数 NTT ）],
  date: "2025-10-23",
  tags: (
    blog-tags.alg,
    blog-tags.temp,
    blog-tags.tech,
  ),
  show-outline: false,
)

#set text(size: 8pt)

= Template
== NTT convolution

#zebraw(
  numbering: true,
  ```cpp
  template <ll mod = 998244353, ll g = 3>
  vector<ll> mul(vector<ll> a, vector<ll> b) {
    Z power = [&](ll a, ll b) -> ll {
      ll r = 1;
      for (; b; b >>= 1, a = a * a % mod) {
        if (b & 1) r = r * a % mod;
      }
      return r;
    };
    int M = a.size() + b.size() - 1u, N = 1;
    while (N < M) N <<= 1;
    vector<int> r(N);
    FOR(i, 1, N) r[i] = r[i / 2] / 2 | (i % 2 ? N / 2 : 0);
    Z ntt = [&](vector<ll> &a, bool inv) -> void {
      a.resize(N);
      FOR(i, N) if (i < r[i]) swap(a[i], a[r[i]]);
      for (int sz = 1; sz < N; sz <<= 1) {
        ll wm = power(inv ? g : power(g, mod - 2), (mod - 1) / sz / 2);
        for (int i = 0; i < N; i += sz * 2) {
          for (int k = 0, w = 1; k < sz; ++k, w = w * wm % mod) {
            ll &x = a[i + k + sz], &y = a[i + k], t = w * x % mod;
            std::tie(x, y) = pair((y + mod - t) % mod, (y + t) % mod);
          }
        }
      }
      if (ll in = power(N, mod - 2); inv) FOR(i, N) a[i] = a[i] * in % mod;
    };
    ntt(a, 0);
    ntt(b, 0);
    FOR(i, N) a[i] = a[i] * b[i] % mod;
    ntt(a, 1);
    a.resize(M);
    return a;
  }
  ```,
)

== MTT convolution

#zebraw(
  ```cpp
  constexpr ll m0 = 167772161, g0 = 3,
               m1 = 469762049, g1 = 3,
               m2 = 998244353, g2 = 3;

  constexpr ull mod_pow(ull a, ull b, ull mod) {
    a %= mod;
    ull r = 1;
    FOR(32) {
      if (b & 1) r = r * a % mod;
      a = a * a % mod;
      b >>= 1;
    }
    return r;
  }

  ll CRT(ull a0, ull a1, ull a2, ull mod) {
    static constexpr ull x1 = mod_pow(m0, m1 - 2, m1),  // 104391568
                         x2 = mod_pow(m0 * m1 % m2, m2 - 2, m2),  // 575867115
                         p01 = m0 * m1;  // 78812994116517889
    ull c = (a1 - a0 + m1) * x1 % m1;
    ull ans = a0 + c * m0;
    c = (a2 - ans % m2 + m2) * x2 % m2;
    return (ans + p01 % mod * c) % mod;
  }

  vector<ll> mtt(vector<ll> a, vector<ll> b, ll mod) {
    vector<ll> c0 = ntt_convolution<m0, g0>(a, b);
    vector<ll> c1 = ntt_convolution<m1, g1>(a, b);
    vector<ll> c2 = ntt_convolution<m2, g2>(a, b);
    const int N = len(c0);
    vector<ll> c(N);
    FOR(i, N) c[i] = CRT(c0[i], c1[i], c2[i], mod);
    return c;
  }
  ```,
)
