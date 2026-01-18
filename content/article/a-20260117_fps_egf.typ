#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "EGF Learn Memo",
  desc: [指数型生成函数学习笔记],
  date: "2026-01-19",
  tags: (
    blog-tags.alg,
    blog-tags.train,
    blog-tags.tech,
    blog-tags.rec
  ),
  show-outline: true,
)

#set text(size: 8pt)

#let msk = "■";
#let HL(s) = text(size: 9pt)[*#s*]
#let tab = text[#h(8pt)]
#let endl = linebreak()

= 指数型生成函数（EGF）笔记

== 种类与指数型生成函数定义

将种类 $A$ 视为满足下列条件的一类结构物：
- 对任意有限集合 $X$ ，定义另一个有限集合 $A(x)$ 
- 对有限集合 $X, Y$ ，若 $abs(X)!= abs(Y)$ ，则 $abs(A(X)) != abs(A(Y))$
- 对有限集合 $X, Y$ ，若 $X != Y$ 则 $A(x) inter B(x) = emptyset $

记 $A_n:=A({1, 2, 3, ..., n})$ ，定义 $A$ 的指数型生成函数为 $
  A(x) := sum_(i=0)^infinity abs(A_n) x^n/n!
$

$A$ 的自变量元素 $1, 2, 3, ..., n$ 的类型可以是任何东西，使用时可以按需解释为“球”、“ n 元集合”、“有根树”、“森林”、”环“等

总的来说就是某个带标号结构？

== 一些种类和 EGF 的例子
- 置换：令 $S(X)$ 为集合 $X$ 的所有置换构成的集合，因为 $n!$ 元集合的置换有 $n!$ 个，所以
$
  S(x) = sum_(n>=0) n! x^n / n! = 1 / (1-x)
$
- 有限集合：令 $E(X) = {X}$ （也就是只有自己一个元素）。有 $abs(E_n) = 1$ ，其 EGF 为：
$
  E(x) = sum_(n>=0) x^n / n! = e^x
$
- n 元集合：
$
  E_n (x) = x^n / n!
$
- 奇数大小集合：
$
  E_"odd" (x) = (e^x - e^(-x)) / 2 = sinh(x)
$
- 非空集合：
$
  E_"noempty"(x) = E(x) - E_0(x) = e^x - 1
$
- 环：
$
  C(x) = sum_(n>=1) (n - 1)! x^n / n! = log(1 / (1-x))
$

== 卷积
定义种类 $A, B$ 的卷积为：
$
  (A * B)(X) := union.sq_(S union.sq T = X) A(S) * B(T)
$
就是将两个标号结构按集合划分的方式拼起来。

令 $n := abs(X)$ 则
$
  (A * B)(X) = A(x)B(x)
$

#pagebreak()

=== 例题

#HL[问题1]

将 $N$ 个带标号球分成 3 个集合：大小是 $a$ 的倍数的集合，大小是 $b$ 的倍数的集合，大小是 $c$ 的倍数的集合，且 $a, b, c$ 互不相同，问有多少分法

#HL[解答]
$
  [x^N / N!] F_a (x)F_b (x) F_c (x)
$

#HL[问题2]

将 $N$ 个有标号球分到 k 个非空无标号盒子里，并按顺序排成一个列表，求方案数

#HL[解答]

令 $f(x) = E_"noempty" (x)$ ，答案为 
$
  [x^N / N!] f(x)^K
$

#HL[问题3 bell number]

将 $N$ 个有标号球分到若干个非空无标号盒子里，并按顺序排成一个列表，求方案数

#HL[解答]

令 $f(x) = E_"noempty" (x)$ ，答案为 
$
  [x^N / N!] sum_(i>=0) f(x)^i = [x^N / N!] 1 / (1 - f(x))
$


#HL[问题4]

求 ${1, 2, ..., N}$ 的排列 ${p_1, ..., p_N}$ 中满足 对所有 $i$ ，$i != p_i$ 的方案数（错排数）

#HL[解答]

设要求的是 $[x^N / N!]f(x)$ ，$g(x) = E(x)$ ，有 $f * g = S$ ，所以
$
  f =  S g^(-1) = sum_(i>=0) x^i sum_(k>=0) ((-1)^k x^k) / k! 
$
$
  [x^N / N!]f(x) = sum_(k=0)^N (-1)^k / k!
$

这样一种利用 *未知 EGF \* 已知 EGF 1 = 已知 EGF 2* 的式子求未知 EGF 的方法会经常用到

#HL[问题5 ARC009C]

求 ${1, 2, ..., N}$ 的排列 ${p_1, ..., p_N}$ 中满足 恰好 $k$ 个 $i$ 错排的方案数

#HL[解答]

错排数 EGF $f(x)$ ，$g(x) = E_k (x)$ ，答案为 
$
  [x^N / N!](f * g) = sum_(i=0)^(K) (-1)^i / i! * 1/(N-K)!
$

#pagebreak()

#HL[问题6]

将 $K$ 个带标号球放入 $N$ 个带标号盒子，要求盒子非空，求方案数

#HL[解答]

一个盒子放至少一个球的 EGF ：
$
  f = e^x - 1
$
$N$ 个盒子 $K$ 个球的答案就是 
$
  [x^K / K!]f^N
$

或者采用 [4] 中的做法，令答案为 $[x^N / N!]f(x)$ ，$g(x) = E(x)$ ，有 $h(x) = sum_(i>=0) i^K / i! x^i$

使得 $f * g = h$ ，答案为 $[x^N / N!]h(x)g(x)^(-1)$

#HL[问题7 yukicoder No.1100]

将 $K$ 个带标号球放入 $N$ 个带标号盒子，要求空盒子个数为奇数，求方案数

#HL[解答]

取 [6] 的 EGF f(x)，答案为 $[x^N / N!] f(x) E_"odd" (x)$