#import "/typ/templates/blog.typ": *
#show: main-en.with(
  title: "Typst Syntax",
  desc: [List of Typst Syntax, for rendering tests.],
  date: "2025-05-27",
  tags: (
    blog-tags.programming,
    blog-tags.typst,
  ),
)

= Raw Blocks

This is an inline raw block `class T`.

This is an inline raw block ```js class T```.

This is a long inline raw block ```js class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {}; class T {};```.

Js syntax highlight are handled by syntect:

```js
class T {};
```

Typst syntax hightlight are specially handled internally:

```typ
#let f(x) = x;
```

= Equations

Example from #link("https://github.com/ahxt/academic-homepage-typst/blob/55e76cb813f0096070fdda57dc81e13697af66b2/content/blog/grpo.typ")[academic-homepage-typst: GRPO.]

$
  cal(J)_text("PPO")(theta) = bb(E)_((q,a)~cal(D))
  [
    min ( (pi_theta(o_t|q, o_(<t))) / (pi_(theta_text("old"))(o_t|q,o_(<t))) hat(A)_t,
      "clip" ( (pi_theta(o_t|q, o_(<t))) / (pi_(theta_text("old"))(o_t|q,o_(<t))), 1 - epsilon, 1 + epsilon ) hat(A)_t ) ]
$


- $r_(i,t)(theta) = (pi_(theta)(o_(i,t) | q, o_(i,<t))) / (pi_(theta_text("old"))(o_(i,t) | q,o_(i,<t)))$ is the importance sampling ratio for the $i$-th response at time step $t$.
- $hat(A)_(i,t)$ is the advantage for the $i$-th response at time step $t$.

= Images

#figure(image("/public/shr/gui.png", alt: "Slint GUI"), caption: "Slint GUI (Absolute Path)")

#figure(image("../../public/shr/gui.png", alt: "Slint GUI"), caption: "Slint GUI (Relative Path)")
