#import "/typ/templates/blog.typ": *

#show: main.with(
  title: "Test Math",
  desc: [测试公式渲染],
  date: "2026-03-19",
  tags: ("typst", "math"),
)
= Test Math

令 $i$ 种颜色出现 $S$ 次的方案数为 $A_i$ 答案为 $ sum_i^M w_i A_i $

对于任意一种颜色数分配 $c_i$ ，方案数是 $ N!/(product_i^M (c_i!)) $

令每个颜色的生成函数为 $ g_i(x) = sum_c^infinity x^c/c! = e^x $

所有颜色的总生成函数就是 $ G(x) = product_i^M g_i (x) = product_i^M (sum_c^N x^c/c!) $

$ [x^N]G(x) = sum_(sum c_i = N) 1/(product c_i !) $

需要的就是 $ N! [x^N] G(x) = N! [x^N] g(x)^M $

用另一个变量 $y$ 来标记 出现了 $s$ 次的颜色 $ f(x, y) = sum_(c!=s) x^c/c! + y x^s/s! = e^x + (y-1)x^s/s! $
$ F(x, y) = f(x, y)^M $
$ A_k = N! [x^N] [y^k] F(x, y) $

答案为 $ sum_(k=0)^M w_k A_k = N! [x^N] sum_(k=0)^M w_k [y^k]F(x, y) $

$
  F(x, y) & = (e^x + (y-1)x^s/s!)^M \
          & = sum_(k=0)^M binom(M, k) ((y-1)x^s/s!)^k (e^x)^(M-k) \
          & = sum_(k=0)^M binom(M, k) (y - 1)^k (x^(s k)/(s!)^k e^((M-k)x))
$

令 $ T_k (x) = binom(M, k) x^(s k)/(s!)^k e^((M-k)x) $

变换 $F(x, y)$
$
  sum_(k=0)^M w_k [y^k]F(x, y) & = sum_(k=0)^M w_k [y^k] sum_(i=0)^M (y-1)^i T_i(x) \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^M w_k [y^k] (y-1)^i \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^M w_k [y^k] sum_(j=0)^i binom(i, j) (-1)^(i-j) y^j \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^M w_k binom(i, k) (-1)^(i-k) \
                               & = sum_(i=0)^M T_i (x) sum_(k=0)^i w_k binom(i, k) (-1)^(i-k)
$

令
$ d_i = sum_(k=0)^i w_k binom(i, k) (-1)^(i-k) $
故
$ sum_(k=0)^M w_k [y^k]F(x, y) = sum_(k=0)^M d_k T_k (x) $

现在要求 $ N![x^N]sum_(k=0)^M d_k T_k (x) $

$
  [x^N]T_k (x) & = [x^N]binom(M, k) x^(s k)/(s!)^k e^((M-k)x) \
               & = binom(M, k) 1/(s!)^k [x^(N-s k)]e^((M-k)x) \
               & = binom(M, k) 1/(s!)^k [x^(N-s k)]sum_(i=0)^infinity (M-k)^i / i! x^i \
               & = binom(M, k) 1/(s!)^k (M-k)^(N-s k) / (N-s k)!
$

答案就是
$
  N!sum_(k=0)^M d_k binom(M, k) 1/(s!)^k (M-k)^(N-s k) / (N-s k)!
$


现在求 $d_i$

$
  d_i & = sum_(k=0)^i w_k binom(i, k) (-1)^(i-k) \
      & = sum_(k=0)^i w_k i!/(k! (i-k)!) (-1)^(i-k) \
      & = i!sum_(k=0)^i w_k / k! dot (-1)^(i-k)/(i-k)! \
      & = i![x^i](sum_k w_k/k!)(sum_k (-1)^k/k!)
$

显然是个卷积