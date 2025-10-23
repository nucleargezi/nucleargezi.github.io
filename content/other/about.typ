
#import "/typ/templates/mod.typ": sys-is-html-target

// If the site is not bundled my artwork, don't show it
#let show-artwork = true
#let is-external = state("about:is-external", false)

#let lang-par(lang, body) = {
  show: text.with(lang: lang)
  context if sys-is-html-target {
    let translate = if lang != "en" {
      ("translate": "no")
    }
    html.elem("p", attrs: ("lang": lang) + translate, body)
  } else {
    body
  }
}

#let en = lang-par.with("en")
#let zh = lang-par.with("zh")

#let blog-desc = [
  #zh[
    记录了 Yorisou 的日常与随笔。
  ]
]

#let self-desc = [
  #context if not is-external.get() { blog-desc }

  #zh[
    算法竞赛选手

    想要了解我可以点击头像
  ]
]

#if sys-is-html-target and show-artwork {
  {
    show raw: it => html.elem("style", it.text)
    ```css
    .self-desc .thumbnail-container {
      flex: 0 0 28em;
      border-radius: 0.5em;
      overflow: hidden;
      margin-left: 2em;
      margin-block-start: -5em;
      margin-block-end: 2em;
    }

    .self-desc .thumbnail-container,
    .self-desc .thumbnail {
      float: right;
      width: 28em;
      height: 28em;
    }

    .thumbnail img {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    @media (max-width: 800px) {
      .self-desc {
        display: flex;
        gap: 1em;
        flex-direction: column-reverse;
        align-items: center;
      }
      .self-desc .thumbnail-container {
      margin-left: 0em;
        margin-block-start: 0em;
        margin-block-end: 0em;
      }
      .self-desc .thumbnail-container,
      .self-desc .thumbnail {
        width: 100%;
        height: 100%;
      }
    }
    ```
  }

  let div = html.elem.with("div")

  let artwork = div(
    attrs: (
      class: "thumbnail",
    ),
    html.elem(
      "img",
      attrs: (
        src: "/favicon.svg",
        alt: "Profile Picture",
      ),
    ),
  )

  div(
    attrs: (
      class: "self-desc",
    ),
    {
      context div(
        attrs: (
          class: "thumbnail-container link",
          title: "",
          onclick: if is-external.get() {
            "location.href='https://nucleargezi.github.io/article/personal-info'"
          } else {
            "location.href='/article/personal-info'"
          },
        ),
        artwork,
      )
      div(self-desc)
    },
  )
} else {
  self-desc
}

#context if is-external.get() {
  show "Yorisou Realm": link.with("https://nucleargezi.github.io")

  [= My Blog]

  blog-desc
}
