#let int-pow(base, exp) = {
  if exp <= 0 {
    1
  } else {
    base * int-pow(base, exp - 1)
  }
}

#let tree-label(depth, k, l, r) = {
  if depth + 1 == k {
    str(l)
  } else {
    $[#l, #r)$
  }
}

#let tree-node(x, y, label, radius: 11pt, text-size: 9pt) = [
  #place(
    top + left,
    dx: x - radius,
    dy: y - radius,
    circle(radius: radius, fill: white, stroke: 0.7pt + black),
  )
  #place(top + left, dx: x - 2.8 * radius, dy: y - 0.7em)[
    #box(width: 5.6 * radius, inset: 0pt)[
      #set text(size: text-size)
      #align(center)[#label]
    ]
  ]
]

#let tree-edge(x1, y1, x2, y2, stroke: 0.6pt + black) = {
  place(line(start: (x1, y1), end: (x2, y2), stroke: stroke))
}

#let full-nary-tree(
  k,
  n,
  level-gap: 16mm,
  leaf-gap: 7mm,
  node-radius: 9pt,
  text-size: 7pt,
) = {
  assert(k >= 1, message: "k must be >= 1")
  assert(n >= 1, message: "n must be >= 1")

  let leaf-count = int-pow(n, k - 1)
  let width = if leaf-count == 1 { 2 * node-radius + 4pt } else { (leaf-count - 1) * leaf-gap + 2 * node-radius + 4pt }
  let height = (k - 1) * level-gap + 2 * node-radius + 4pt

  let x-of-leaf(i) = node-radius + 2pt + i * leaf-gap
  let y-of-depth(depth) = node-radius + 2pt + depth * level-gap

  let draw-subtree(depth, l, r) = {
    let span = r - l
    let x = (x-of-leaf(l) + x-of-leaf(r - 1)) / 2
    let y = y-of-depth(depth)
    let items = ()
    if depth + 1 < k {
      let child-span = span / n
      for child in range(n) {
        let cl = l + child * child-span
        let cr = cl + child-span
        let cx = (x-of-leaf(cl) + x-of-leaf(cr - 1)) / 2
        let cy = y-of-depth(depth + 1)
        items.push(tree-edge(x, y + node-radius, cx, cy - node-radius))
        items.push(draw-subtree(depth + 1, cl, cr))
      }
    }
    items.push(
      tree-node(
        x,
        y,
        tree-label(depth, k, l, r),
        radius: node-radius,
        text-size: text-size,
      ),
    )
    [#for item in items { item }]
  }

  box(width: width, height: height, inset: 0pt, clip: false)[
    #draw-subtree(0, 0, leaf-count)
  ]
}

#full-nary-tree(4, 3)
