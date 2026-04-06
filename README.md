# bl

一个基于 `Astro` 和 `astro-typst` 的静态博客项目. 

这个仓库目前不依赖现成博客主题, 页面和样式基本都是按项目需要写的. 除了普通文章页之外, 还包含 `algorithm`, `icpc`, `library` 等独立页面, 其中 `library` 页面会把外部算法库的测试覆盖情况渲染成可浏览的树状视图. 

## 技术栈

- `Astro 6`
- `astro-typst`
- `TypeScript`
- `smol-toml`
- `pnpm`

CI 当前使用：

- `Node.js 22`
- `pnpm 10`

## 项目结构

```text
.
├── content/                # 文章内容, 目前以 Typst 文件为主
├── public/                 # 静态资源
├── src/
│   ├── components/         # Astro 组件
│   ├── layouts/            # 页面布局
│   ├── lib/                # 数据整理与工具函数
│   ├── pages/              # 路由页面
│   └── styles/             # 全局样式与分页面样式
├── tests/                  # Node 原生测试
├── typ/                    # Typst 模板
└── .github/workflows/      # GitHub Pages 部署流程
```

更具体一点：

- `src/pages/index.astro` 是首页入口. 
- `src/pages/article/` 管理文章列表页和文章详情页. 
- `src/pages/library/` 是算法库测试可视化页面, 依赖 `state.toml`. 
- `src/lib/blog.ts` 放博客内容相关的辅助逻辑. 
- `src/lib/library-state.ts` 负责解析 `library/state.toml` 并整理成页面需要的数据结构. 
- `src/styles/library.css` 是 `library` 页面样式入口, 再拆分到 `src/styles/library/*.css`. 

## 内容开发

### 文章内容

当前文章内容放在 `content/article/`, 仓库里已有的文件以 `.typ` 为主. 这个项目通过 `astro-typst` 把 Typst 内容渲染成网页, 所以新增文章时, 优先参考现有文章文件和 `typ/templates/` 里的模板组织方式. 

如果你要调整文章页行为, 通常需要一起检查这些位置：

- `content/article/`
- `src/pages/article/index.astro`
- `src/pages/article/[...slug].astro`
- `src/layouts/BlogPost.astro`
- `src/lib/blog.ts`

### 页面样式

样式目前按页面和模块拆分：

- 通用布局样式在 `src/styles/base.css`, `src/styles/layout.css`
- 首页样式在 `src/styles/home/`
- `library` 页面样式在 `src/styles/library/`

如果后续继续维护 `library` 页面, 建议保持现在的拆分方式：

- `page.css` 负责页面布局
- `summary.css` 负责顶部统计卡片
- `tree.css` 负责树状列表
- `modal.css` 负责详情弹窗

对应入口文件是 `src/styles/library.css`, 由它统一 `@import` 子文件. 

## Library 页面数据流

`library` 页面不是纯静态文案页, 它依赖一个 TOML 状态文件：

- 数据文件：`src/pages/library/state.toml`
- 页面入口：`src/pages/library/index.astro`
- 数据解析：`src/lib/library-state.ts`
- 展示组件：`src/components/LibraryTree.astro`

`state.toml` 当前记录的信息包括：

- 模板文件覆盖情况
- 测试文件状态
- 模板依赖关系
- 测试到模板的映射
- 最近一次外部测试运行的摘要

如果之后要继续扩展这个页面, 优先遵循现在的分层：

1. 先在 `src/lib/library-state.ts` 里完成 TOML 解析和数据归一化. 
2. 再把页面需要的字段传给 `src/pages/library/index.astro`. 
3. 最后在 `src/styles/library/` 下做局部样式调整. 

这样会比把解析逻辑直接塞进页面文件更容易维护. 

## 测试

仓库当前测试集中在 `library` 页面相关逻辑, 位于 `tests/`：

- `tests/library-page.test.ts`
- `tests/library-state.test.ts`
- `tests/library-styles.test.ts`

项目暂时没有在 `package.json` 里单独声明 `test` 脚本, 可以直接用 Node 原生测试运行：

```bash
node --test tests/*.test.ts
```

如果后续测试范围继续扩大, 建议把常用命令补进 `package.json` 的 `scripts`. 

## 部署

项目通过 GitHub Actions 自动部署到 GitHub Pages：

- 工作流文件：`.github/workflows/gh-pages.yml`
- 触发条件：`main` 分支推送, 手动触发, 每 12 小时定时构建一次
- 构建产物目录：`dist/`

CI 里会额外安装一组字体, 再执行 `pnpm build`. 如果本地渲染结果和线上不一致, 优先检查是否和字体环境有关. 

`astro.config.mjs` 当前配置了：

- `site = "https://nucleargezi.github.io"`
- `astro-typst` 默认按 `html` 模式渲染

如果后续改成项目页部署或自定义域名, 这里和 GitHub Pages 配置都要一起检查. 