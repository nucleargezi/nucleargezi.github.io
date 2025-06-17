#import "../comment-sys.typ": *

#show: main-zh.with(
  title: "评论系统",
  desc: [我为博客搭建了简易评论系统],
  date: "2025-06-17T11:11:54+08:00",
  tags: (
    blog-tags.programming,
    blog-tags.software-engineering,
    blog-tags.golang,
    blog-tags.typst,
  ),
)

#show: local-rules

想为博客添加合适的评论系统，主要考虑以下几点：

#argument-points[
  + 后端需求应尽量简化，特别需要考虑到国内外均可访问。
  + 最好能隐藏邮箱等个人信息。虽然许多邮箱并非机密，但我不希望我的博客内包含这些邮件信息。
  + 操作简便，避免过程太过复杂而劝退评论。
  + 少使用或不使用 JavaScript。
]

这个评论系统支持：
- markdown语法和数学公式。
- 用户提及和评论回复。
- 邮件通知。

= 传统邮件方案

首先研究mailto协议方案。这确实是一个古老而广泛支持的协议，但我怀疑除了泄露邮箱地址以外，这样的链接究竟被使用过多少次。它无需JavaScript和后端，但存在缺陷：
- 点击mailto链接会后浏览器会启动用户邮件客户端。而多数人未配置客户端，就会导致转至Outlook/Thunderbird。最坏情况下，用户可能会选择放弃评论。这违背了@arg:3。
- mailto链接会暴露邮箱地址，虽不是什么大问题，但违背了@arg:2。

= GitHub作为后端

没有后端像是不可能的，它只是以另一种幽灵的方式出现。另一种流行方案是利用GitHub issues。看起来不错，但这依然存在缺陷：
- 这要求用户拥有GitHub账户（非普适），违背了@arg:3。
- GitHub在某些国家不可用，违背了@arg:1。
- 我还未考虑@arg:4，因为这只是一个加分项。但此类系统通常需JavaScript渲染评论。

= 自建评论系统

既然我们曾经用Golang搭建了简单的HTTP（文件）服务器，为何不在同服务器部署简易评论系统？已知他们已经可以访问那些前端资源，那么他们应该也能对同一个服务器发起请求。虽存在缺点，却是良好起点。

需要后端框架吗？我认为不必——毕竟我们的目标不是构建每秒处理10万ops的评论系统。Golang实现如下：

#comment-backend

现在，我们可以定期从后端获取评论并在静态博客中渲染。

= Comentario 系统

我也调研过一些自托管评论系统，例如 #link("https://comentario.app")[Comentario]。但我对里面的说明有些困惑。他们这样写道，#link("https://docs.comentario.app/en/installation/requirements/#sqlite")[要求: Sqlite：]

#quote(block: true)[
  - 不可扩展性：数千条评论的规模下可能还能工作良好，但超过此数量性能将显著下降

  尽管如此，作为最小化试用方案，或用于（低流量）个人博客时，SQLite 或许仍可接受。
]

我并无冒犯之意，且 Comentario 美观的前提下还免费。或许是我经验不足（我从未管理过含数千评论的博客），我直接联想到的只能是 Comentario 过于臃肿而不适合用 SQLite 作后端以处理十万乃至百万的评论。

= 继续开发土制评论系统

这并不意味着我会最终一定使用我的自建系统。我只是稍作开发以便我能回复朋友一个星期前发的评论。

#figure(
  code-image.with(class: "center")(theme => [
    // #set page(width: auto, height: auto, margin: 5mm, fill: white)
    #let node-text = text.with(white, font: "New Computer Modern")
    #let colors = (green.darken(20%), eastern, blue.lighten(20%))
    #let edge = edge.with(stroke: theme.main-color)

    #diagram(
      edge-stroke: 1pt,
      node-corner-radius: 5pt,
      edge-corner-radius: 8pt,
      mark-scale: 80%,

      node((0, 0), node-text[任意用户\ 提交评论], fill: colors.at(0)),
      node((0, 2), node-text[邮件所有者\ 取消确认], fill: colors.at(0)),

      node((1, 0), node-text[后端接收/\ 过滤评论], fill: colors.at(1)),
      node((1, 1), node-text[站点所有者发送\ 授权邮件], fill: colors.at(1)),
      node((1, 2), node-text[站点所有者\ 删除评论], fill: colors.at(1)),

      node((3, 0), node-text[前端构建\ 未授权评论], fill: colors.at(2)),
      node((3, 1), node-text[前端构建\ 已授权评论], fill: colors.at(2)),
      node((3, 2), node-text[前端构建\ 移除评论], fill: colors.at(2)),

      edge((0, 0), "r", "-}>"),
      edge((0, 2), "r", "-}>"),
      edge(
        (0, 0),
        "dd",
        "--}>",
      ),

      edge((1, 0), "d", "-}>"),
      edge((1, 1), "d", "-}>"),

      edge(
        (1, 1),
        (0, 2),
        "-}>",
        label: edge-box[抢先授权],
        label-anchor: "center",
        label-angle: -10deg,
      ),

      edge((3, 0), "d", "-}>"),
      edge((3, 1), "d", "-}>"),

      edge((1, 0), "rr", "-}>"),
      edge((1, 1), "rr", "-}>", label: edge-box[等待一端时间]),
      edge((1, 2), "rr", "-}>"),
    )
  ]),
  caption: "满足最低后端需求的简易评论系统。",
)

简单描述一下流程：

== 第一步：发送与渲染在未授权的评论

无需注册或 OAuth 认证就能评论，算是极度简化了流程。

后端只需仅向所有者发送邮件，因此可轻松部署于 Cloudflare Workers 等分布式计算服务。

- 不过我目前还是用的 Golang 后端，因为他还能跑。等哪一天我对我现在的构建不满意了，或许会写一写 Cloudflare Workers实现。

== 第二步：授权流程

邮件确认采用抢先授权机制：
+ 系统向邮件所有者发送通知。
+ 邮件所有者无需回复确认邮件。系统将待一段时间后移除评论的 `[未授权]` 标签。
  - 若邮件所有者24小时内无后续评论，则自动移除 `[未授权]` 标签。
  - 若监测到邮件所有者活动，则立即移除标签。

= 基于 Typst 的定制标记

评论采用扩展语法的 Markdown 格式，由 Typst 的 `cmark` 包渲染，支持两类自定义语法：

== `[user:name]`

用户可提及"当前博客中出现过"的其他用户。渲染成 `#hash` 链接，无需引入 JavaScript处理跳转。

- 暂未考虑同名用户。不如说，我的博客会出现两名"Steven"用户吗？

== `[comment:id]`

用户可通过 id 回复同文章下的其他评论。渲染时将显示评论首行内容并生成锚点链接。

被提及用户将收到邮件通知。

#figure(
  code-image.with(class: "center")(theme => [
    // #set page(width: auto, height: auto, margin: 5mm, fill: white)
    #let node-text = text.with(white, font: "New Computer Modern")
    #let colors = (green.darken(20%), eastern, blue.lighten(20%))
    #let edge = edge.with(stroke: theme.main-color)

    #diagram(
      edge-stroke: 1pt,
      node-corner-radius: 5pt,
      edge-corner-radius: 8pt,
      mark-scale: 80%,

      node((0, 0), node-text[任意用户\ 提交评论], fill: colors.at(0)),
      node((0, 2), node-text[被提及用户\ 接收通知], fill: colors.at(0)),

      node((1, 1), node-text[站点所有者发送\ 通知邮件], fill: colors.at(1)),

      edge((0, 0), (1, 1), "-}>"),
      edge((0, 0), "dd", "--}>"),

      edge((1, 1), (0, 2), "-}>", label: edge-box[密送邮件], label-anchor: "center", label-angle: -10deg),
    )
  ]),
  caption: "用户提及通知流程。",
)

"邮件密送"机制隐藏其他被提及者邮箱地址，符合 @arg:2 隐私要求。

= 后记：gravatar 头像

有的人说 gravatar 头像功能不错。想法不错，但考虑有损邮箱隐私，我最终还是没这么做：

- gravatar 通过邮箱哈希值生成头像 URL，但攻击者可建立哈希库反查真实邮箱。
- 即使不试图破解哈希，通过 gravatar URL 仍可追踪和推测用户活动轨迹。

这不是什么大问题，但我们最好还是不用这些服务以规避可能的隐私问题。
