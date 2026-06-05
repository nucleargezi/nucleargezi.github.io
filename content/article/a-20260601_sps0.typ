#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "SPS Learn Memo 0",
  desc: [集合幂级数学习笔记0],
  date: "2026-06-01",
  tags: ("alg", "sps"),
)

= 集合幂级数 0

本文为 #text(rgb("#f92323"))[yorisou] 学习集合幂级数科技的笔记，大量内容翻译自外文资料

== 符号

令 $n$ 为任意非负整数, 固定一个环 $K$ , 在 cp 中常为整数或者 modint, 

#let K = $K^(2^n)$
#let ml = $star$

将由 $K$ 的元素组成的长度为 $2^n$ 的所有序列的集合记作 $K^(2^n)$

将 $[0, 2^n)$ 的所有非负整数看作 ${0, 1, ..., n - 1}$ 的子集, 使用如下集合记号:

- $emptyset$ : 空集, 对应 $0$
- $s inter t$ : $s$ 和 $t$ 的交集, 对应位运算 $s amp t$
- $s union t$ : $s$ 和 $t$ 的并集, 对应位运算 $s|t$
- $s subset t$ : $s$ 是 $t$ 的子集, 等价于 $s =  s amp t$ 或者 $t = s|t$
- $s = t union.sq u$ : $s = t union u$ 且 $emptyset = t inter u$ , 即 $s$ 为 $t, u$ 的不交并
- $|s|$ : $s$ 集合的元素个数, 相当于 popcount(s) 

 
== 子集卷积 集合幂级数

#let sp(x, n) = $#x = (#x _0, ..., #x _(2^#n - 1))$
#let spa = sp($a$, $n$)
#let spb = sp($b$, $n$)
#let spc = sp($c$, $n$)

对于 $ZZ$ 中元素构成的序列 #spa 以及 #spb

有 #spc 满足 $c_k = sum_(k = i union.sq j) a_i b_j$

这一关系 $a ml b = c$ 就是子集卷积, 即 subset convolution

这定义了一种二元运算 $ml : #K times #K -> #K$

$ml$ 是结合的, 对于 $a, b, c in #K$ , 有 $(a ml b) ml c = a ml (b ml c)$

要证明这个, 只需要证明对于任意 $s$ 两边的第 $s$ 项相同, 左边和右边的第 $s$ 项, 都是对满足 
$s = t_0 union.sq t_1 union.sq t_2$ 的三元组 $(t_0, t_1, t_2)$ 将 $a_t_0 b_t_1 c_t_2$ 求和得到的, 也可以理解为, 左边将 $t_2$ 固定的部分合并求和, 右边将 $t_0$ 固定的部合并求和

在 #K 中加法和数乘定义为逐项的加法和数乘, 乘法定义为 subset convolution , 得到的结构就是集合幂级数, 即 set power series (SPS)

乘法的单位元是第 0 项为 1 , 其他为 0 的数列

用代数学的语言来说, $(#K, +, ml)$ 是一个 $K$-代数, 其结构射 $K --> #K$ 为 $x mapsto (x, 0, 0, ...)$

== 与多项式的关系
准备 $n$ 个变量 $x_0, x_1, ..., x_(n-1)$ 对集合 $s$ 记 $x^s = prod_(i in s) x_i$

将序列 #spa 改写成 $a(x) = sum_0^(2^n-1) a_s x^s$

此时可以知道 subset convolution $a ml b$ 能用多项式这样描述:

计算多项式乘积 $a(x)b(x)$ , 但是忽略那些对于某个 $i$ , 可以被 $x_i^2$ 整除的项

用代数的语言来说, 这意味着集合幂级数与如下多项式环的商环同构:
$
  K[x_0, ..., x_(n-1)]/(x_0^2, ..., x_(n-1)^2)
$
配合这种记法, 接下来用下面的记号: 将 $a$ 的第 $s$ 项 $a_s$ 写作 $[x^s]a$

采用多项式记法时, 注意集合和非负整数的同一视可能导致混淆

== 子集卷积的计算

对于 $a, b in #K$ , $a ml b$ 可以 $O(n 2^(2n))$ 计算, 如果按定义写暴力, 需要 $O(3^n)$ 时间(枚举子集), 因此需要更巧妙的算法, 首先讨论 or convolution

=== Zeta 变换与 Mobius 变换

zeta 变换和 mobius 变换是定义在偏序集合上的概念, 即使是同一个词, 根据上下文, 所指的内容也可能发生变化

- 对于 $a in #K$ , 定义 $zeta a in #K$ 为 $[x^s]zeta a = sum_(t subset.eq s) a_t$
将 $zeta: #K -> #K$ 称作 zeta 变化

- 将 $zeta$ 的逆变换记作 $mu$ , 称为 mobius 变换
给定 $a$ 时, $zeta a$ 和 $mu a$ 可以 $O(n 2^n)$ 计算

=== Or Convolution

对于 $a, b in #K$ , 定义它们的 or convolution $c in #K$ 为 $[x^s]c = sum_(s = i union k) a_i b_k$

它和 subset convolution 很相似, 但没有不交的限制

or convolution 可以 $O(n 2^n)$ 计算, 方法如下:

考虑 $zeta c$ 是个怎样的序列
$
  [x^s]zeta c = sum_(t subset.eq s) c_t = sum_(i union k subset.eq s) a_i b_k = sum_(i subset.eq s) a_i sum_(k subset.eq s) b_k = (zeta a)_s (zeta b)_s
$

因此, 根据这个式子, $zeta c$ 可以 $O(n 2^n)$ 求出, 再对其进行 mobius 变换, 就可以 $O(n 2^n)$ 算出 c

=== Subset Convolution

对于序列 #spa , 这里不直接使用它, 而是定义一个以 $X$ 为变量的单变量多项式 $a'$ , 其中 $a_s ' = a_s X^(|s|)$

例如, 当 $n = 2$ 时, $a' = (a_0, a_1 X, a_2 X, a_3, X^2)$

对于序列 $b$ , 也同样进行定义

令 $a'$ 和 $b'$ 的 Or convolution 为 $c'$ , 这里的底层环不再是 $K$ , 而是多项式环 $K[X]$ , 但仍然可以同样定义并计算. 也就是说对每个 $s$ , 有
$
  c_s ' = sum_(s = i union k) a_i ' b_k ' = sum_(s = i union k) a_i b_k X^(|i| + |k|)
$
对满足 $s = i union k$ 的 $i, k$ , 有
$
  i inter k = emptyset <==> |i| + |k| = |s|
$
因此, 只要取 $c_s '$ 中 $X^(|s|)$ 的系数, 就可以得到 $c_s$ 

所以 subset convolution 可以这样计算:
- 将 $a, b$ 的各个元素分别替换为单变量多项式 a_s X^(|s|), b_s X^(|s|) , 然后计算它们的 zeta 变换 $zeta a, zeta b$ 
- 对于每个 $s$ 计算关于 $X$ 的多项式乘积 $(zeta a)_s (zeta b)_s$ 并对的到的序列进行 mobius 变换 
- 从得到的序列 $c'$ 的各个元素 $c_s '$ 中取出 $X^(|s|)$ 的系数, 将其作为 $c_s$