#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "SAIS 模板",
  desc: [一份 On SA],
  date: "2025-10-21",
  tags: (
    blog-tags.alg,
    blog-tags.temp,
    blog-tags.tech,
  ),
  show-outline: false,
)

#set text(size: 8pt)

#zebraw(
  ```cpp
  struct SA {
    int N;
    vector<int> sa, as, lcp;

    template <typename Str>
    SA(Str s) : N(len(s)), as(N), lcp(N - 1) {
      Z f = s;
      unique(f);
      for (Z &x : s) x = lower_bound(f, x);
      sa = SAIS(s);
      FOR(i, N) as[sa[i]] = i;
      int w = 0;
      for (Z i : as) {
        if (w) --w;
        if (i < N - 1) {
          while (std::max(sa[i], sa[i + 1]) + w < N and
                 s[sa[i] + w] == s[sa[i + 1] + w]) ++w;
          lcp[i] = w;
        }
      }
    }

    template <typename Str>
    vector<int> SAIS(Str a) {
      const int N = len(a), M = QMAX(a) + 1;
      vector<int> pos(M + 1), x(M), sa(N), val(N), lms;
      for (Z c : a) pos[c + 1]++;
      FOR(i, M) pos[i + 1] += pos[i];
      vector<char> s(N);
      FOR_R(i, N - 1) s[i] = a[i] != a[i + 1] ? a[i] < a[i + 1] : s[i + 1];

      Z make = [&](const vector<int> &ls) -> void {
        fill(all(sa), -1);
        Z L = [&](int i) { if (i >= 0 and not s[i]) sa[x[a[i]]++] = i; };
        Z S = [&](int i) { if (i >= 0 and s[i]) sa[--x[a[i]]] = i; };
        FOR(i, M) x[i] = pos[i + 1];
        FOR_R(i, len(ls)) S(ls[i]);
        FOR(i, M) x[i] = pos[i];
        L(N - 1);
        FOR(i, N) L(sa[i] - 1);
        FOR(i, M) x[i] = pos[i + 1];
        FOR_R(i, N) S(sa[i] - 1);
      };

      Z f = [&](int i) { return i == N or (not s[i - 1] and s[i]); };

      Z same = [&](int i, int k) {
        do {
          if (a[i++] != a[k++]) return false;
        } while (not f(i) and not f(k));
        return f(i) and f(k);
      };

      FOR(i, 1, N) if (f(i)) lms.ep(i);
      make(lms);
      if (len(lms)) {
        int p = -1, w = 0;
        for (int x : sa) if (x and f(x)) {
          if (p != -1 and same(p, x)) --w;
          val[p = x] = w++;
        }
        vector<int> b = lms;
        for (int &x : b) x = val[x];
        b = SAIS(b);
        for (int &x : b) x = lms[x];
        make(b);
      }
      return sa;
    }
  };
  ```,
)