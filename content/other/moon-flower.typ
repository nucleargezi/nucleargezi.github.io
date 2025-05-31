

// https://dribbble.com/shots/19821521-Sakura-Geometric-Pattern

// #set page(width: 1000pt, height: 1000pt)
#set page(width: auto, height: auto, margin: 0pt, fill: none)

#let fill-color = black

#let bx-center = (50%, 50%)

#let edge = (
  l0: (50%, 4.2%),
  s0: (50%, 10%),
)
#let edge-l = edge.l0.at(0) - edge.l0.at(1)
#let edge-s = edge.s0.at(0) - edge.s0.at(1)
#for i in range(0, 5) {
  // cosine
  let name = "l" + str(i)
  let angle = (2 * calc.pi * i / 5) - calc.pi / 2
  let pt = (bx-center.at(0) + edge-l * calc.cos(angle), bx-center.at(1) + edge-l * calc.sin(angle))
  edge.insert(name, pt)
}
#for i in range(5) {
  // sine
  let name = "s" + str(i)
  let angle = (2 * calc.pi * i / 5) - calc.pi / 2 - (calc.pi * 2 / 10)
  let pt = (bx-center.at(0) + edge-s * calc.cos(angle), bx-center.at(1) + edge-s * calc.sin(angle))
  edge.insert(name, pt)
}

#let acc = 640pt

#let place-on(pt, body) = {
  place(dx: pt.at(0), dy: pt.at(1), body)
}
#let place-circle(pt, radius, fill: red) = {
  place-on(pt, move(dx: -radius, dy: -radius, circle(fill: fill, radius: radius)))
}

#let mp(pt, dx, dy) = {
  (pt.at(0) + dx, pt.at(1) + dy)
}
#let p-mul(pt, factor) = {
  (pt.at(0) * factor, pt.at(1) * factor)
}

#let r-add(pt1, pt2) = {
  (pt1.at(0) + pt2.at(0), pt1.at(1) + pt2.at(1))
}
#let r-sub(pt1, pt2) = {
  (pt1.at(0) - pt2.at(0), pt1.at(1) - pt2.at(1))
}


#let mk-angle(pt1, pt2, pt3) = {
  let r = 100pt
  let v1 = r-sub(pt2, pt1)
  let v2 = r-sub(pt3, pt1)
  let dot-product = (r * (v1.at(0) * v2.at(0) + v1.at(1) * v2.at(1))).pt()
  let magnitude-v1 = calc.sqrt((r * (v1.at(0) * v1.at(0) + v1.at(1) * v1.at(1))).pt())
  let magnitude-v2 = calc.sqrt((r * (v2.at(0) * v2.at(0) + v2.at(1) * v2.at(1))).pt())
  calc.acos(dot-product / (magnitude-v1 * magnitude-v2))
}

#let flower-points(pt1, pt2, dir: left) = {
  // get
  let center = bx-center
  let center-to-l = r-sub(pt1, center)
  let center-to-l-rotate-90 = r-add(
    center-to-l,
    if dir == left {
      (-center-to-l.at(1), center-to-l.at(0))
    } else {
      (center-to-l.at(1), -center-to-l.at(0))
    },
  )

  let pt3 = center-to-l-rotate-90
  let angle-s1-l1-pt3 = mk-angle(pt2, pt1, pt3)

  // place(line(start: pt1, end: pt2))
  // place(line(start: bx-center, end: r-add(bx-center, center-to-l)))

  let ux = r-sub(r-add(bx-center, center-to-l-rotate-90), pt1)
  let uy = r-sub(pt1, bx-center)

  let u-pt(pt) = {
    r-add(pt1, r-add(p-mul(ux, pt.at(0) / edge-l), p-mul(uy, pt.at(1) / edge-l)))
  }

  // let ctrl-1 = r-add(p-mul(ux, .5% / edge-l), pt1)
  let ctrl-1 = u-pt((0.5%, 0%))
  // place(line(start: pt1, end: ctrl-1))
  let ctrl-2 = u-pt((2.5%, 0.1%))
  // place(line(start: pt1, end: ctrl-2))
  let ctrl-3 = u-pt((8.5%, 1%))
  // place(line(start: pt1, end: ctrl-3))
  let ctrl-4 = u-pt((16.8%, 0%))
  // place(line(start: pt1, end: ctrl-4))

  // curve.cubic(mp(pt1, 8.5%, 0%), mp(pt1, 8.5%, -3%), mp(pt1, 17%, -3%)),
  // curve.cubic(mp(pt1, 17% + 8.5%, -3%), edge.s1, edge.s1),
  // curve.line(edge.s1),
  // (
  //   curve.quad(auto, mp(pt1, .5%, -0%)),
  //   curve.quad(auto, mp(pt1, 2.5%, -0.1%)),
  //   curve.quad(auto, mp(pt1, 8.5%, -1%)),
  //   curve.quad(auto, mp(pt1, 17%, 0%)),
  //   curve.quad(auto, pt2),
  // )
  (
    ctrl-1,
    ctrl-2,
    ctrl-3,
    ctrl-4,
    pt2,
  )
}

#let flower-curve(pt1, pt2, dir: left) = {
  place(
    curve(
      stroke: stroke(paint: black),
      curve.move(pt1),
      ..flower-points(pt1, pt2, dir: dir),
    ),
  )
}

// #let flower-petal(s0, l0, s1) = {
//   let (p-left, p-left2) = flower-points(s0, l0, dir: left)
//   let (p-right, p-right2) = flower-points(s1, l0, dir: right)
//   let special-center = r-add(bx-center, r-add(r-sub(p-left, s0), r-sub(p-right, s1)))
//   place(
//     curve(
//       // stroke: stroke(paint: black),
//       fill: fill-color,
//       fill-rule: "even-odd",
//       curve.move(special-center),
//       curve.line(p-left),
//       ..p-left2.map(it => curve.quad(auto, it)),
//       curve.close(mode: "straight"),
//       curve.move(p-right),
//       ..p-right2.map(it => curve.quad(auto, it)),
//       curve.line(special-center),
//       curve.close(mode: "straight"),
//     ),
//   )
// }

#let flower-petal-pts(s0, l0, s1) = {
  let l0-center = r-sub(l0, bx-center)
  let center-adjust = r-add(bx-center, p-mul(l0-center, 0.05))
  let s0-l0 = r-sub(s0, l0)

  // let s0-center = p-mul(r-sub(s0, center-adjust), 0.25)
  // let s1-center = p-mul(r-sub(s1, center-adjust), 0.25)
  // let center-left = r-add(center-adjust, s0-center)
  // let center-right = r-add(center-adjust, s1-center)
  //
  //
  let s0-center = r-add(p-mul(r-sub(s0, center-adjust), 0.62), p-mul(s0-l0, 0.05))
  let s1-center = p-mul(r-sub(s1, center-adjust), 0.58)
  let center-left = r-add(bx-center, s0-center)
  let center-right = r-add(bx-center, s1-center)


  let l1-center = p-mul(r-sub(l0, center-adjust), 0.36)
  let center-mid = r-add(center-adjust, l1-center)

  let l0-s0 = r-sub(l0, s0)
  let l0-s1 = r-sub(l0, s1)
  let s0-adjust = r-add(s0, p-mul(l0-s0, 0.02))
  let s1-adjust = r-add(s1, p-mul(l0-s1, 0.02))


  let p-left2 = flower-points(l0, s0-adjust, dir: right)
  let p-right2 = flower-points(l0, s1-adjust, dir: left)

  // let special-center = r-add(bx-center, r-add(r-sub(p-left, s0), r-sub(p-right, s1)))
  let special-center = bx-center
  (
    curve.move(l0),
    ..p-left2.map(it => curve.quad(auto, it)),
    curve.quad(auto, center-left),
    curve.line(center-mid),
    curve.move(l0),
    ..p-right2.map(it => curve.quad(auto, it)),
    // curve.quad(auto, center-right),
    curve.line(center-right),
    curve.line(center-mid),
    curve.close(mode: "straight"),
  )
}

#let flower-petal(s0, l0, s1) = {
  place(
    curve(
      fill: fill-color,
      fill-rule: "even-odd",
      ..flower-petal-pts(s0, l0, s1),
    ),
  )
}

#let flower-petal-pts-adjust(s0, l0, s1) = {
  let s0-adjust = r-add(bx-center, p-mul(r-sub(s0, bx-center), 1.017))

  flower-petal-pts(s0-adjust, l0, s1)
}

#let flower-curve() = {
  place(
    curve(
      fill: fill-color,
      fill-rule: "even-odd",
      ..flower-petal-pts-adjust(edge.s0, edge.l0, edge.s1),
      ..flower-petal-pts-adjust(edge.s1, edge.l1, edge.s2),
      ..flower-petal-pts-adjust(edge.s2, edge.l2, edge.s3),
      ..flower-petal-pts-adjust(edge.s3, edge.l3, edge.s4),
      ..flower-petal-pts-adjust(edge.s4, edge.l4, edge.s0),
    ),
  )
}

#box(
  width: acc,
  height: acc,
  // fill: blue.lighten(80%),
  {
    // flower-curve(edge.l0, edge.s0, dir: right)
    // flower-curve(edge.l4, edge.s0)
    // flower-curve(edge.l1, edge.s1, dir: right)
    // flower-curve(edge.l0, edge.s1)
    // flower-curve(edge.l2, edge.s2, dir: right)
    // flower-curve(edge.l1, edge.s2)
    // flower-curve(edge.l3, edge.s3, dir: right)
    // flower-curve(edge.l2, edge.s3)
    // flower-curve(edge.l4, edge.s4, dir: right)
    // flower-curve(edge.l3, edge.s4)

    // flower-petal(edge.l4, edge.s0, edge.l0)
    // flower-petal(edge.l0, edge.s1, edge.l1)
    // flower-petal(edge.l1, edge.s2, edge.l2)
    // flower-petal(edge.l2, edge.s3, edge.l3)
    // flower-petal(edge.l3, edge.s4, edge.l4)

    // flower-petal(edge.s0, edge.l0, edge.s1)
    // flower-petal(edge.s1, edge.l1, edge.s2)
    // flower-petal(edge.s2, edge.l2, edge.s3)
    // flower-petal(edge.s3, edge.l3, edge.s4)
    // flower-petal(edge.s4, edge.l4, edge.s0)

    flower-curve()

    place-circle(bx-center, 12% * acc, fill: fill-color)

    // place-circle(bx-center, 1% * acc)
    // for i in range(0, 5) {
    //   let name = "l" + str(i)
    //   place-circle(edge.at(name), 1% * acc)
    //   place-on(edge.at(name), move(dx: 1%, text(size: 3% * acc, name)))
    //   place(
    //     curve(
    //       stroke: stroke(paint: black, dash: "dashed"),
    //       curve.move(bx-center),
    //       curve.line(edge.at(name)),
    //     ),
    //   )
    // }
    // for i in range(0, 5) {
    //   let name = "s" + str(i)
    //   // place-circle(edge.at(name), 1% * acc)
    //   // place-on(edge.at(name), move(dx: 1%, text(size: 3% * acc, name)))
    //   place(
    //     curve(
    //       stroke: stroke(paint: black, dash: "dashed"),
    //       curve.move(bx-center),
    //       curve.line(edge.at(name)),
    //     ),
    //   )
    // }
    // place(
    //   curve(
    //     stroke: stroke(paint: black),
    //     curve.move(edge.l0),
    //     // curve.cubic(mp(edge.l0, 8.5%, 0%), mp(edge.l0, 8.5%, -3%), mp(edge.l0, 17%, -3%)),
    //     // curve.cubic(mp(edge.l0, 17% + 8.5%, -3%), edge.s1, edge.s1),
    //     // curve.line(edge.s1),
    //     curve.quad(auto, mp(edge.l0, .5%, -0%)),
    //     curve.quad(auto, mp(edge.l0, 2.5%, -0.1%)),
    //     curve.quad(auto, mp(edge.l0, 8.5%, -1%)),
    //     curve.quad(auto, mp(edge.l0, 17%, 0%)),
    //     curve.quad(auto, edge.s1),
    //     // curve.quad(auto, bx-center),
    //   ),
    // )
    // place(
    //   curve(
    //     stroke: stroke(paint: black),
    //     curve.move(edge.l0),
    //     // curve.cubic(mp(edge.l0, 8.5%, 0%), mp(edge.l0, 8.5%, -3%), mp(edge.l0, 17%, -3%)),
    //     // curve.cubic(mp(edge.l0, 17% + 8.5%, -3%), edge.s1, edge.s1),
    //     // curve.line(edge.s1),
    //     curve.quad(auto, mp(edge.l0, -.5%, -0%)),
    //     curve.quad(auto, mp(edge.l0, -2.5%, -0.1%)),
    //     curve.quad(auto, mp(edge.l0, -8.5%, -1%)),
    //     curve.quad(auto, mp(edge.l0, -17%, 0%)),
    //     curve.quad(auto, edge.s0),
    //     // curve.quad(auto, bx-center),
    //   ),
    // )
    // place-circle(edge.l0, 1% * acc)
    // place-on(edge.l1, rect(fill: fill-color, width: 10% * acc))

    // curve(
    //   fill: black.lighten(20%),
    //   // stroke: blue,
    //   curve.move((0%, 50%)),
    //   curve.line((100%, 50%)),
    //   curve.cubic(none, (90%, 0%), (50%, 0%)),
    //   curve.close(),
    // )
  },
)
