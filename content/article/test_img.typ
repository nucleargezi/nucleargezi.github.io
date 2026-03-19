#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Test Image",
  desc: [测试图片渲染],
  date: "2026-03-19",
  tags: ("typst", "image"),
)
= Test Image

你也可以直接插入链接：#link("https://github.com/nucleargezi/acm-icpc/tree/master", [GitHub 仓库]).

#figure(image("/public/images/typst-grid.svg", alt: "yorisou"), caption: "yorisou")


#image("/public/images/typst-grid.svg", width: 70%)
