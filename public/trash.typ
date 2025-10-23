#set page(paper: "a4", margin: 2cm, fill: none)
#set par(justify: true)
#set text(
  font: (
    (name: "Latin Modern Roman", covers: "latin-in-cjk"),
    "Noto Serif CJK SC",
    "Noto Color Emoji",
  ),
  size: 10.5pt,
  lang: "zh",
)
#show link: set text(fill: rgb("#302e80"))
#let info_card(content) = {
  rect(
    width: 100%,
    fill: rgb("#ffefef"),
    stroke: rgb("#e2e8f0") + 1pt,
    radius: 12pt,
    inset: 20pt,
    content,
  )
}
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
#let avatar = {
  rect(
    // fill: rgb("#fff8f8"),
    width: 120pt,
    height: 120pt,
    [
      #align(center + horizon)[
        #text(size: 60pt, image("/public/imgss/hd.jpg"))
      ]
    ],
  )
}
#align(center)[
  #info_card[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 20pt,
      align: (center, left),
      [
        #avatar
      ],
      [
        #v(10pt)
        #text(
          size: 28pt,
          weight: "bold",
          fill: rgb("#2d3748"),
          "Yorisou",
        )
        #grid(
          // columns: (auto, 1fr),
          row-gutter: 6pt,
          column-gutter: 10pt,
          text("📚", size: 12pt) + text("  BJTU undergrad, year 4, majoring in CS", size: 12pt),
          text("🎯", size: 12pt) + text("  XCPCer", size: 12pt),
          text("🥪  Codeforces: ", size: 12pt) + text("2342", size: 12pt, fill: rgb("#ffc85a"), weight: "bold"),
          text("🚀  Atcoder: ", size: 12pt) + text("2010", size: 12pt, fill: rgb("#f5ed67"), weight: "bold"),
          text("📧", size: 12pt) + text("  QQ：604223110", size: 12pt),
          text("💎", size: 12pt) + text("  Interested in: galgame / competitive programming", size: 12pt),
        )
      ],
    )
  ]
  #v(10pt)
  #align(left)[
    #text(
      size: 17pt,
      weight: "bold",
      fill: rgb("#2d3748"),
      "Timeline",
    )
  ]
  #v(10pt)
  #align(left)[
    #timeline_item(
      "🥇",
      "05/2025",
      "2025年北京市大学生程序设计竞赛暨“小米杯”全国邀请赛",
      "2025 - 2026 China Collegiate Programming Contest, Beijing Site",
      "金奖\nGold Medal",
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
      "2024 - 2025 International Collegiate Programming Contest, Kunming Site",
      "银奖\nSilver Medal",
    )
  ]
]