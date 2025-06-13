#import "/typ/templates/blog.typ": *
#show: main-zh.with(
  title: "Typst 语法",
  desc: [Typst 语法列表，用于渲染测试。],
  date: "2025-05-27",
  tags: (
    blog-tags.programming,
    blog-tags.typst,
  ),
)

= 原始块

这是一个内联原始块 `class T`。

这是一个内联原始块 ```js class T```。

这是一个长内联原始块 ```js class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {};```。

Js 语法高亮由 syntect 处理：

```js
class T {};
```

Typst 语法高亮由内部特殊处理：

```typ
#let f(x) = x;
```

= 公式

例子来自 #link("https://github.com/ahxt/academic-homepage-typst/blob/55e76cb813f0096070fdda57dc81e13697af66b2/content/blog/grpo.typ")[academic-homepage-typst: GRPO。]

$
  cal(J)_text("PPO")(theta) = bb(E)_((q,a)~cal(D))
  [
    min ( (pi_theta(o_t|q, o_(<t))) / (pi_(theta_text("old"))(o_t|q,o_(<t))) hat(A)_t,
      "clip" ( (pi_theta(o_t|q, o_(<t))) / (pi_(theta_text("old"))(o_t|q,o_(<t))), 1 - epsilon, 1 + epsilon ) hat(A)_t ) ]
$


- $r_(i,t)(theta) = (pi_(theta)(o_(i,t) | q, o_(i,<t))) / (pi_(theta_text("old"))(o_(i,t) | q,o_(i,<t)))$ 是第 $i$ 个响应在时间步 $t$ 的重要性采样比率。
- $hat(A)_(i,t)$ 是第 $i$ 个响应在时间步 $t$ 的advantage。


= 图片

#figure(image("/public/shr/gui.png", alt: "Slint GUI"), caption: "Slint GUI (Absolute Path)")

#figure(image("../../../public/shr/gui.png", alt: "Slint GUI"), caption: "Slint GUI (Relative Path)")
