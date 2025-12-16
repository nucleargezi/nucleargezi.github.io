#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Static Toptree 模板",
  desc: [一天一棵 Toptree],
  date: "2025-11-05",
  tags: (
    blog-tags.alg,
    blog-tags.temp,
    blog-tags.tech,
  ),
  show-outline: true,
)

#set text(size: 8pt)

= Static Toptree Template
== 这是一份静态 Toptree 模板

用于解决树上动态 dp 问题，即单点修改 查询整棵树的 dp 值

模板传入一个 DP 类，包含维护的数据 X ， compress 和 rake 方法

使用时传入一个初始化节点信息函数用于 build 

#zebraw(
  numbering: true,
  ```cpp
  template<typename DP>
  struct STT {
    using X = DP::X;
    int N;
    vector<vector<int>> &g;
    vector<int> fa, sz, hd, ls, rs, A, B;
    vector<char> vis;
    vector<X> dp;
    int tt;

    STT(vector<vector<int>> &g, int r = 0)
        : N(len(g)), g(g), fa(N), sz(N, 1), hd(N),
          ls(N, -1), rs(ls), A(N), B(N), vis(N), tt(0) {
      ff(r, -1), dfs(r, r);
      A = fa, iota(all(B), 0);
      dfs_build(r);
    }

    void ff(int n, int f) {
      fa[n] = f;
      int mx = -1, id = -1, t = -1, L = len(g[n]);
      FOR(i, L) {
        int x = g[n][i];
        if (x == f) continue;
        if (t == -1) t = i;
        ff(x, n), sz[n] += sz[x];
        if (chmax(mx, sz[x])) id = x;
      }
      if (id == -1 or t == -1) return;
      FOR(i, L) if (g[n][i] == id) return swap(g[n][i], g[n][t]);
    }
    void dfs(int n, int h) {
      hd[n] = h;
      for (bool f = 1; int x : g[n]) if (x != fa[n]) 
        dfs(x, f ? h : x), f = 0;
    }
    vector<int> HP(int x) {
      vector<int> r{x};
      f: int n = r.back(), fa = A[n];
      for (int t : g[n]) 
        if (t != fa and hd[t] == hd[x]) {
          r.ep(t);
          goto f;
        }
      return r;
    }
    int newnode(int l, int r, int a, int b, int c) {
      int x = len(fa);
      fa.ep(-1), ls.ep(l), rs.ep(r);
      A.ep(a), B.ep(b), vis.ep(c);
      return fa[l] = fa[r] = x;
    }
    PII dfs_build(int n) {
      Z pa = HP(n);
      vector<PII> st{{0, pa[0]}};
      Z merge = [&]() {
        Z [hh, kk] = pop(st);
        Z [h, k] = pop(st);
        st.ep(max(h, hh) + 1, newnode(k, kk, A[k], B[kk], 1));
      };
      int sz = len(pa);
      FOR(i, 1, sz) {
        min_heap<PII> q;
        int k = pa[i];
        q.eb(0, k);
        for (int n = pa[i - 1], fa = A[n], f = 1; int x : g[n]) if (x != fa) {
          if (f) f = 0; 
          else q.eb(dfs_build(x));
        }
        while (len(q) > 1) {
          Z [h, i] = pop(q);
          Z [hh, ii] = pop(q);
          if (ii == k) swap(i, ii);
          int n = newnode(i, ii, A[i], B[i], 0);
          if (k == i) k = n;
          q.eb(max(h, hh) + 1, n);
        }
        st.ep(q.top());
        while (1) {
          int n = len(st);
          if (n > 2 and
              (st[n - 3].fi == st[n - 2].fi or st[n - 3].fi <= st[n - 1].fi)) {
            Z [h, k] = pop(st);
            merge(), st.ep(h, k);
          } else if (n > 1 and st[n - 2].fi <= st[n - 1].fi) merge();
          else break;
        }
      }
      while (len(st) > 1) merge();
      return st[0];
    }
    
    void build(Z f) {
      dp.resize(N * 2 - 1);
      FOR(i, N) dp[i] = f(i);
      FOR(i, N, N + N - 1) upd(i);
    }
    void set(int x, X c) {
      for (dp[x] = c, x = fa[x]; x != -1; x = fa[x]) upd(x);
    }
    X prod() { return dp[(N - 1) << 1]; }
    
    void upd(int i) {
      const X &L = dp[ls[i]], &R = dp[rs[i]];
      dp[i] = vis[i] ? DP::compress(L, R) : DP::rake(L, R);
    }
  };
  ```
)