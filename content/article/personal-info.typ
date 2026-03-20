#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "About",
  desc: [一点自我介绍],
  date: "2025-10-20",
  tags: (),
)

#set text(size: 8pt)

= Personal-Info

== About Me

// #figure(image("/public/trash.svg", alt: "yorisou"), caption: "yorisou")

#import "/public/trs.typ": *

#align(center)[
  #profile-card[
    #text(size: 7.6pt, weight: "bold", fill: accent-pink, "PERSONAL PROFILE")
    #grid(
      columns: (106pt, 1fr),
      column-gutter: 18pt,
      align: (center, left),
      [
        #avatar-frame()
        #text(
          size: 10pt,
          weight: "bold",
          style: "italic",
          fill: text-strong,
        )[Yorisou]
        #grid(
          columns: (auto, auto),
          column-gutter: 8pt,
          align: center,
          [
            #link("https://github.com/nucleargezi", [#image("/public/images/logo/github.svg", width: 10pt)])
          ],
          [
            #link("https://space.bilibili.com/285769347", [#image("/public/images/logo/bilibili.svg", width: 10pt)])
          ],
        )
      ],
      [
        #v(30pt)
        #text(
          size: 10pt,
          fill: text-strong,
          style: "italic",
        )[
          - BJTU undergrad, year 4, majoring in Computer Science
          - ACMer
          - #box(width: 55pt)[Codeforces:] #text(fill: accent-red)[2450]
          - #box(width: 55pt)[Atcoder:] #text(fill: accent-gold)[2010]
          - QQ: 604223110
          - Interest in: Galgame | Competitive Programming
        ]
      ],
    )
  ]

  #v(14pt)
  #align(left)[
    #text(
      style: "italic",
      size: 13pt,
      weight: "bold",
      fill: rgb("#2d3748"),
    )[Timeline]
  ]
  #v(10pt)
  #align(left)[
    #for (index, item) in timeline_entries.enumerate() {
      timeline_entry(
        item,
        is-first: index == 0,
        is-last: index == timeline_entries.len() - 1,
      )
    }
  ]
]

== About Yorisou Realm

主要是记录个人学习，以及一些乱七八糟的东西

== 阿巴阿巴

在这里放一个在线卷积

```cpp
// 2e5 888ms , offline 88ms
// (i, f[i], g[i]) return c[i]; (N + M - 1) all ins
template <typename mint>
struct online_conv {
  static_assert(mint::can_ntt());
  vc<mint> f, g, h, a, b;
  vc<vc<mint>> ff, gg;
  int p;

  online_conv() : p(0) {}

  inline mint operator()(mint fi, mint gi) { return add(fi, gi); }

  mint add(mint fi, mint gi) {
    f.ep(fi);
    g.ep(gi);
    int k = lowbit(p + 2), w = 1 << k, s;
    if (p + 2 == w) {
      a = f;
      sh(a, w << 1);
      ntt(a, 0);
      ff.ep(a.begin(), a.begin() + w);

      b = g;
      sh(b, w << 1);
      ntt(b, 0);
      gg.ep(b.begin(), b.begin() + w);
      FOR(i, w << 1) a[i] *= b[i];

      s = w - 2;
      sh(h, 2 * s + 2);
    } else {
      a.assign(f.end() - w, f.end());
      sh(a, w << 1);
      ntt(a, 0);
      FOR(i, w << 1) a[i] *= gg[k][i];

      b.assign(g.end() - w, g.end());
      sh(b, w << 1);
      ntt(b, 0);
      FOR(i, w << 1) a[i] += b[i] * ff[k][i];
      s = w - 1;
    }
    ntt(a, 1);
    FOR(i, s + 1) h[p + i] += a[s + i];
    return h[p++];
  }
};
```
