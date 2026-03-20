
#let timeline_entries = (
  (
    tier: "gold",
    date: "11/2025",
    title: "第 11 届 CCPC 中国大学生程序设计竞赛郑州站",
    subtitle: "2025 - 2026 China Collegiate Programming Contest, Zhengzhou Site",
    award_cn: "金奖",
    award_en: "Gold Medal",
  ),
  (
    tier: "gold",
    date: "11/2025",
    title: "第 50 届 ICPC 国际大学生程序设计竞赛区域赛沈阳站",
    subtitle: "2025 - 2026 International Collegiate Programming Contest, Shenyang Site",
    award_cn: "金奖",
    award_en: "Gold Medal",
  ),
  (
    tier: "gold",
    date: "05/2025",
    title: "2025年北京市大学生程序设计竞赛暨“小米杯”全国邀请赛",
    subtitle: "2025 - 2026 China Collegiate Programming Contest, Beijing Site",
    award_cn: "金奖",
    award_en: "Gold Medal",
  ),
  (
    tier: "silver",
    date: "11/2024",
    title: "第49届 ICPC 国际大学生程序设计竞赛区域赛昆明站",
    subtitle: "2024 - 2025 International Collegiate Programming Contest, Kunming Site",
    award_cn: "银奖",
    award_en: "Silver Medal",
  ),
  (
    tier: "gold",
    date: "10/2024",
    title: "第49届 ICPC 国际大学生程序设计竞赛区域赛南京站",
    subtitle: "2024 - 2025 International Collegiate Programming Contest, Nanjing Site",
    award_cn: "金奖",
    award_en: "Gold Medal",
  ),
  (
    tier: "silver",
    date: "10/2024",
    title: "第10届 CCPC 中国大学生程序设计竞赛区域赛济南站",
    subtitle: "2024 - 2025 International Collegiate Programming Contest, Jinan Site",
    award_cn: "银奖",
    award_en: "Silver Medal",
  ),
)


#let soft-pink = rgb("#fff5f7")
#let milk-white = rgb("#fffdfd")
#let card-stroke = rgb("#eed8df")
#let text-strong = rgb("#46343d")
#let text-soft = rgb("#8b7480")
#let accent-pink = rgb("#d77291")
#let accent-red = rgb("#e25555")
#let accent-gold = rgb("#ffdf28")

#let timeline-row-height = 40.5pt
#let timeline-rail-segment = 18pt
#let timeline-node-size = 17.5pt
#let timeline-date-column = 62pt
#let timeline-marker-column = 26pt
#let timeline_color_none = rgb(0, 0, 0, 0)
#let timeline-date-fill = rgb("#757575")
#let timeline-title-fill = rgb("#212121")
#let timeline-sub-fill = rgb("#757575")
#let timeline-rail-fill = rgb("#bdbdbd")
#let timeline-gold-border = rgb("#efbf04")
#let timeline-gold-fill = rgb("#ffffff")
#let timeline-gold-award-fill = rgb("#ffbd24")
#let timeline-silver-border = rgb("#c0c7d0")
#let timeline-silver-fill = rgb("#bcc3cc")
#let timeline-silver-award-fill = rgb("#7b8594")

// 奖牌 svg
#let timeline_tier_style(tier) = if tier == "gold" {
  (
    node-fill: timeline-gold-fill,
    node-stroke: timeline-gold-border,
    icon-path: "/public/images/logo/timeline-medal-dark.svg",
    award-fill: timeline-gold-award-fill,
  )
} else {
  (
    node-fill: timeline-silver-fill,
    node-stroke: timeline-silver-border,
    icon-path: "/public/images/logo/timeline-medal-light.svg",
    award-fill: timeline-silver-award-fill,
  )
}
// 时间线的seg
#let timeline_rail_segment(visible) = align(center + horizon)[
  #rect(
    width: 1pt,
    height: timeline-rail-segment,
    fill: if visible { timeline-rail-fill } else { timeline_color_none },
    inset: 0pt,
  )
]
// 时间线的🏅
#let timeline_node(tier) = {
  let style = timeline_tier_style(tier)

  align(center + horizon)[
    #rect(
      width: timeline-node-size,
      height: timeline-node-size,
      radius: 999pt,
      fill: style.at("node-fill"),
      stroke: style.at("node-stroke") + 1pt,
      inset: 4pt,
      [
        #align(center + horizon)[
          #image(
            style.at("icon-path"),
            width: 14pt,
            height: 14pt,
            fit: "contain",
          )
        ]
      ],
    )
  ]
}
// 线
#let timeline_marker(tier, is-first: false, is-last: false) = block(
  width: timeline-marker-column,
  height: timeline-row-height,
  above: 0pt,
  below: 0pt,
  inset: -12pt,
)[
  #grid(
    rows: (timeline-rail-segment, timeline-node-size, timeline-rail-segment),
    row-gutter: 0pt,
    align: center,
    [
      #move(
        dy: -2.5pt,
        timeline_rail_segment(not is-first),
      )
    ],
    [
      #timeline_node(tier)
    ],
  )
]

#let timeline_date(date) = block(
  width: timeline-date-column,
  height: 30pt,
  above: 0pt,
  below: 0pt,
  inset: (left: 0pt, right: 12pt),
)[
  #align(right + horizon)[
    #text(size: 8.3pt, fill: timeline-date-fill)[#date]
  ]
]

#let timeline_content(item, award-fill) = block(
  width: 100%,
  height: timeline-row-height,
  above: 0pt,
  below: 0pt,
  inset: 0pt,
)[
  #pad(x: 12pt, y: 8.5pt)[
    #grid(
      columns: (1fr, auto),
      column-gutter: 10pt,
      row-gutter: 5pt,
      align: (left, right),
      [
        #text(size: 8.8pt, fill: timeline-title-fill)[#item.at("title")]
      ],
      [
        #text(size: 8.8pt, fill: award-fill)[#item.at("award_cn")]
      ],

      [
        #text(size: 7.7pt, style: "italic", fill: timeline-sub-fill)[#item.at("subtitle")]
      ],
      [
        #text(size: 7.7pt, style: "italic", fill: timeline-sub-fill)[#item.at("award_en")]
      ],
    )
  ]
]

#let timeline_entry(item, is-first: false, is-last: false) = {
  let tier = item.at("tier")
  let style = timeline_tier_style(tier)

  block(
    width: 100%,
    above: 0pt,
    below: 0pt,
    inset: 0pt,
  )[
    #grid(
      columns: (timeline-date-column, timeline-marker-column, 1fr),
      column-gutter: 0pt,
      align: (left, center, left),
      [
        #timeline_date(item.at("date"))
      ],
      [
        #timeline_marker(tier, is-first: is-first, is-last: is-last)
      ],
      [
        #timeline_content(item, style.at("award-fill"))
      ],
    )
  ]
}

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
