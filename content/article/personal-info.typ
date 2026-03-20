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

#let soft-pink = rgb("#fff5f7")
#let milk-white = rgb("#fffdfd")
#let card-stroke = rgb("#eed8df")
#let text-strong = rgb("#46343d")
#let text-soft = rgb("#8b7480")
#let accent-pink = rgb("#d77291")
#let accent-red = rgb("#e25555")
#let accent-gold = rgb("#ffdf28")

#let profile-card(content) = {
  rect(
    width: 100%,
    // fill: soft-pink,
    stroke: 0pt,
    radius: 5pt,
    inset: 18pt,
    content,
  )
}
#let avatar-frame() = {
  rect(
    width: 100%,
    fill: milk-white,
    inset: 0pt,
    [
      #rect(
        width: 100%,
        fill: soft-pink,
        stroke: rgb("#f0d4dc") + 0.6pt,
        inset: 3pt,
        image(
          "/public/images/hs.jpg",
          width: 100%,
          // height: 100%,
          fit: "cover",
        ),
      )
    ],
  )
}

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

  #let timeline_item(awemoji, date, title, subtitle, award) = [
    #grid(
      columns: (42pt, 10pt, 1fr, 110pt),
      column-gutter: 10pt,
      align: (right, center, left, right),
      [
        #text(size: 12pt, fill: rgb("#718096"), date)
      ],
      [
        #align(center)[
          #text(size: 15pt, awemoji)
        ]
      ],
      [
        #text(size: 11pt, weight: "bold", fill: rgb("#2d3748"), title)

        #text(size: 9pt, fill: rgb("#718096"), subtitle)
      ],
      [
        #align(right)[
          #text(size: 11pt, style: "italic", fill: rgb("#e53e3e"), award)
        ]
      ],
    )
    #v(20pt)
  ]

  #v(14pt)
  #align(left)[
    #text(
      size: 17pt,
      weight: "bold",
      fill: rgb("#2d3748"),
    )[Timeline]
  ]
  #v(10pt)
  #align(left)[
    #timeline_item(
      "🥇",
      "11/2025",
      "第 11 届 CCPC 中国大学生程序设计竞赛郑州站",
      "2025 - 2026 China Collegiate Programming Contest, Zhengzhou Site",
      "金奖\nGold Medal",
    )
    #timeline_item(
      "🥇",
      "11/2025",
      "第 50 届 ICPC 国际大学生程序设计竞赛区域赛沈阳站",
      "2025 - 2026 International Collegiate Programming Contest, Shenyang Site",
      "金奖\nGold Medal",
    )
    #timeline_item(
      "🥇",
      "05/2025",
      "2025年北京市大学生程序设计竞赛暨“小米杯”全国邀请赛",
      "2025 - 2026 China Collegiate Programming Contest, Beijing Site",
      "金奖\nGold Medal",
    )
    #timeline_item(
      "🥈",
      "11/2024",
      "第49届 ICPC 国际大学生程序设计竞赛区域赛昆明站",
      "2024 - 2025 International Collegiate Programming Contest, Kunming Site",
      "银奖\nSilver Medal",
    )
    #timeline_item(
      "🥇",
      "10/2024",
      "第49届 ICPC 国际大学生程序设计竞赛区域赛南京站",
      "2024 - 2025 International Collegiate Programming Contest, Nanjing Site",
      "金奖\nGold Medal",
    )
    #timeline_item(
      "🥈",
      "10/2024",
      "第10届 CCPC 中国大学生程序设计竞赛区域赛济南站",
      "2024 - 2025 International Collegiate Programming Contest, Jinan Site",
      "银奖\nSilver Medal",
    )
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
