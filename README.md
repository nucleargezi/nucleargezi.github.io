# Typst 文章渲染说明

这份文档只解释当前项目里的 Typst 文章渲染链。

- 当前项目只做 HTML 博客渲染
- 不包含 PDF、月刊、归档打印，也没有 `shiroa`
- Typst 文章通过 `astro-typst` 接入 Astro

## 这套渲染链在做什么

一句话版本：

`content/article/*.typ` -> Typst 模板输出 frontmatter -> `astro:content` 读取 -> `render(post)` 渲染到文章页。

这套结构的分工是：

- Typst 负责写文章内容，以及声明文章元信息
- Astro 负责读取文章、生成路由、包页面壳子
- 模板层负责统一 Typst 正文排版规则

如果你以后忘了文章是怎么变成网页的，就顺着这条链看：

1. 在 [content/article/hello.typ](content/article/hello.typ) 写文章
2. 在 [typ/templates/blog.typ](typ/templates/blog.typ) / [typ/templates/shared.typ](typ/templates/shared.typ) 把元信息和样式包起来
3. 在 [src/content.config.ts](src/content.config.ts) 里把 frontmatter 校验成 Astro collection
4. 在 [src/pages/article/[...slug].astro](src/pages/article/[...slug].astro) 里通过 `render(post)` 输出正文
5. 在 [src/layouts/BlogPost.astro](src/layouts/BlogPost.astro) 和 `BaseLayout` 里包页面头部、标题、标签和全站外壳

## 一篇文章怎么写

文章文件放在 `content/article/*.typ`。

最小写法如下：

```typst
#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "文章标题",
  desc: [文章摘要],
  date: "2026-03-19",
  tags: ("tag1", "tag2"),
)

= 一级标题
正文内容。
```

当前项目里的完整示例见 [content/article/hello.typ](content/article/hello.typ)。

它展示了这几类常见内容：

- 标题和正文
- 行内公式与块级公式
- 链接
- 图片
- 代码块

示例：

```typst
#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Hello Typst Blog",
  desc: [一篇用来验证 Astro + Typst 模板、代码块、公式和图片的示例文章。],
  date: "2026-03-19",
  tags: ("hello", "typst"),
)

= Hello
这是正文内容。行内公式示例：$a^2 + b^2 = c^2$。

$
sum_(i = 1)^n i = (n (n + 1)) / 2
$

你也可以直接插入链接：#link("https://github.com/nucleargezi/acm-icpc/tree/master", [GitHub 仓库]).

#image("/public/images/typst-grid.svg", width: 70%)

== Code Example

```cpp
int main() {
  return 0;
}
```
```

说明：

- `#import "/typ/templates/blog.typ": *` 是固定入口
- `#show: main.with(...)` 是固定的文章模板调用方式
- `main` 默认就是中文文章模板，对应 `lang: "zh"`、`region: "cn"`
- 如果要写英文文章，可以用 `main-en`

## frontmatter / 元信息字段

Typst 文章里的这些字段，最后会被 Astro 当成文章数据读取：

| Typst 字段 | 作用 | Astro 中的对应字段 |
| --- | --- | --- |
| `title` | 文章标题 | `post.data.title` |
| `desc` | 摘要 | `post.data.description` |
| `date` | 日期字符串 | `post.data.date` |
| `tags` | 标签数组 | `post.data.tags` |
| `lang` | 语言 | `post.data.lang` |
| `region` | 地区 | `post.data.region` |

这里有一条需要记住的映射：

`desc` -> frontmatter `description` -> Astro `post.data.description`

也就是说：

- 你在 Typst 文章里写的是 `desc`
- 模板层会把它写进 metadata 的 `description`
- Astro 读取后用的字段名是 `description`

这一层转换发生在 [typ/templates/shared.typ](typ/templates/shared.typ)：

- `#metadata(( ... )) <frontmatter>` 把文章元信息暴露给 `astro-typst`
- 里面的 `description: desc` 完成了字段映射

Astro 侧的字段校验在 [src/content.config.ts](src/content.config.ts)：

```ts
schema: z.object({
  title: z.string(),
  date: z.coerce.date(),
  tags: z.array(z.string()).optional(),
  description: z.any().optional(),
  lang: z.string().optional(),
  region: z.string().optional(),
})
```

当前约定固定为：

- `title: string`
- `date: date`
- `tags?: string[]`
- `description?: unknown`
- `lang?: string`
- `region?: string`

## 模板层怎么工作

[typ/templates/blog.typ](typ/templates/blog.typ) 很薄，只做两件事：

- `#import "shared.typ": *`
- 暴露 `main`、`main-zh`、`main-en`

真正的核心在 [typ/templates/shared.typ](typ/templates/shared.typ)。

它主要负责三类事情：

1. 输出 frontmatter
2. 设置基础排版
3. 设置代码块和块级公式规则

### 1. 输出 frontmatter

`shared-template(...)` 接收：

- `title`
- `desc`
- `date`
- `tags`
- `lang`
- `region`
- `body`

然后通过 `#metadata(...) <frontmatter>` 输出给 `astro-typst`，这样 Astro 才能在 `getCollection("blog")` 里读到这些字段。

### 2. 设置基础排版

`article-rules(...)` 里统一定义了正文排版规则，包括：

- 正文字体：`text-fonts`
- 代码字体：`code-fonts`
- 正文字号：`body-size`
- 标题字号：`heading-size(level)`
- 标题上下间距：`heading-block(it)`
- 链接颜色：`link-color`
- 列表缩进：`set list` / `set enum`

这意味着你以后想改 Typst 正文的观感，优先去改 `shared.typ`，而不是改 Astro 页面。

### 3. 设置代码块和公式规则

当前模板没有做复杂语法高亮，只做了基础可读性样式：

- 行内代码：浅背景、小圆角
- 块级代码：整块背景、内边距、圆角、关闭两端对齐
- 块级公式：居中显示，并加上下间距

对应规则在 `article-rules(...)` 里的：

- `show raw.where(block: false)`
- `show raw.where(block: true)`
- `show math.equation.where(block: true)`

当前没有做这些事情：

- 没有复杂代码高亮
- 没有按 HTML / PDF / Web target 分流
- 没有 `shiroa` 提供的 HTML 包装逻辑

## Astro 侧如何接住 Typst

先看 [astro.config.mjs](astro.config.mjs)。

这里启用了 `astro-typst`，并且固定只用 HTML 模式：

```js
typst({
  mode: {
    default: "html",
    detect: () => "html",
  },
})
```

这表示：

- Typst 文章会按 HTML 方式输出
- 当前项目没有 PDF 渲染链

然后看 [src/content.config.ts](src/content.config.ts)。

这里定义了 `blog` collection：

- 从 `content/article/*.typ` 读取文章
- 用 schema 校验 frontmatter

再看 [src/pages/article/[...slug].astro](src/pages/article/[...slug].astro)。

它的职责很单纯：

- `getCollection("blog")` 找到全部文章
- `getStaticPaths()` 为每篇文章生成静态路由
- `render(post)` 产出 `Content`

也就是说，真正把 Typst 正文变成页面内容的关键语句是：

```astro
const { Content } = await render(post);
```

最后，页面壳子由 Astro layout 负责：

- [src/layouts/BlogPost.astro](src/layouts/BlogPost.astro) 负责文章标题、日期、标签、摘要
- `BaseLayout` 负责全站 HTML 外壳、头部导航和全局样式入口

它们不负责 Typst 正文本身，只负责包裹 `Content`。

## 修改时去哪里

以后改东西时，可以直接按这个对照表找入口：

- 改文章字段：`typ/templates/shared.typ` + [src/content.config.ts](src/content.config.ts)
- 改 Typst 正文样式：`typ/templates/shared.typ`
- 改文章页头部、标题区、标签区：`src/layouts/BlogPost.astro`
- 改全站视觉样式：`src/styles/global.css`
- 新增文章：`content/article/*.typ`
- 改文章列表页：`src/pages/article/index.astro`
- 改文章详情页路由接线：`src/pages/article/[...slug].astro`

如果你分不清该改 Typst 还是 Astro，可以用一个简单判断：

- 想改“正文内容长什么样”，先看 Typst 模板
- 想改“网页壳子长什么样”，先看 Astro layout

## 当前限制

这套实现目前有这些边界：

- 只支持 HTML 博客流
- 没有 PDF、月刊、归档打印
- 没有复杂代码高亮
- `description` 在 Astro 侧会做文本归一化

最后这一条的意思是：

- Typst 的 `desc` 不是普通字符串时，Astro 侧会先把它压平成纯文本
- 这样它才能稳定地显示在页面摘要和 `<meta name="description">` 里

相关逻辑在 `src/lib/blog.ts` 的 `normalizeDescription(...)`。

## 最后记一遍最重要的约定

以后写新文章时，优先记住这几个固定点：

- 入口固定：`#import "/typ/templates/blog.typ": *`
- 模板调用固定：`#show: main.with(...)`
- Typst 里写 `desc`
- Astro 里读 `description`
- Typst 控正文样式，Astro 控页面壳子
