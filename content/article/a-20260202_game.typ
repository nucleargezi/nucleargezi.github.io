#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Game Theory",
  desc: [博弈论学习笔记(施工中)],
  date: "2026-02-01",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.rec,
  ),
  show-outline: true,
)

#show raw.where(block: true, lang: "cpp"): it => zebraw(
  numbering: true,
  it,
)

#set text(size: 8pt)

= Nim

哈哈原来我根本不会 Nim 游戏

== Sprague–Grundy 定理

任何无偏, 无循环, 双方可选动作相同, 不能动了结束的游戏局面都等价于一堆 Nim , 多个子游戏的总局面胜利只看所有子游戏的 Grundy 数的 xor 和

== Grundy 数

将一个公平组合游戏的局面用一个非负整数编码, 使这个局面等价于 Nim 中一堆同样大小的石子

对于一个局面 $S$ , 它可以走到的所有后继局面记作 $"move"(S)$ , 则
$
  g(S) = "mex"{g(T) | T in "move"(S)}
$

== 关于胜负

如果将总局面分解为多个独立子游戏 $S_0, S_1, ..., S_k$ , 那么
$
  g("tot") = g(S_0) xor g(S_1) xor ... xor g(S_k)
$
- xor 和为 $0$ 则先手必败
- 否则先手必胜

== 例题

=== #link("https://yukicoder.me/problems/no/102", "Yuki 102")

#HL[题意]

模板题, 若干堆石子, 每次可以取 $[1, 3]$ 枚, 求先手是否必胜

#HL[解答]

游戏中 Grundy 数为 $x mod 4$ , 求异或和即可

```cpp
void Yorisou() {
  VEC(int, a, 4);
  int s = 0;
  for (int x : a) s ^= x & 3;
  print(s == 0 ? "Jiro" : "Taro");
}
```

=== #link("https://yukicoder.me/problems/no/103", "Yuki 103")

#HL[题意]

有 $N$ 个数, 每次可以选一个数字将它整除它的一个质因数 $[1, 2]$ 次, 问先手是否必胜

#HL[解答]

对于每个数字的每种质因子都是一堆石子, Grundy 数为 $p mod 3$

```cpp
void Yorisou() {
  INT(N);
  int s = 0;
  FOR(N) {
    INT(x);
    for (Z [e, p] : factor(x)) s ^= p % 3;
  }
  Bob(s == 0);
}
```

to be continue
