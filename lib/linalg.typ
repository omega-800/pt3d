#let mat-mult-vec = (((a, b, c), (d, e, f), (g, h, i)), (x, y, z)) => (
  a * x + b * y + c * z,
  d * x + e * y + f * z,
  g * x + h * y + i * z,
)

#let cross-product = ((x1, y1, z1), (x2, y2, z2)) => (
  y1 * z2 - z1 * y2,
  z1 * x2 - x1 * z2,
  x1 * y2 - y1 * x2,
)

#let cube-vertices = (((xfrom, xto), (yfrom, yto), (zfrom, zto))) => (
  (xfrom, yfrom, zfrom),
  (xto, yfrom, zfrom),
  (xto, yto, zfrom),
  (xfrom, yto, zfrom),
  (xfrom, yfrom, zto),
  (xto, yfrom, zto),
  (xto, yto, zto),
  (xfrom, yto, zto),
)

#let cube-edges = dim => {
  let vertices = cube-vertices(dim)
  (
    (vertices.at(0), vertices.at(1)),
    (vertices.at(1), vertices.at(2)),
    (vertices.at(2), vertices.at(3)),
    (vertices.at(3), vertices.at(0)),
    (vertices.at(6), vertices.at(7)),
    (vertices.at(7), vertices.at(4)),
    (vertices.at(4), vertices.at(5)),
    (vertices.at(5), vertices.at(6)),
    (vertices.at(0), vertices.at(4)),
    (vertices.at(1), vertices.at(5)),
    (vertices.at(2), vertices.at(6)),
    (vertices.at(3), vertices.at(7)),
  )
}

// TODO:
#let bounds(elem) = {
  ((-5, 5), (-5, 5), (-5, 5))
}

#let intersect-bounds(a, b, larger: true) = {
  let new = ()
  for n in (0, 1, 2) {
    let an = a.at(n)
    let bn = b.at(n)
    if (an == auto) {
      new.push(bn)
    } else if (bn == auto) {
      new.push(an)
    } else if larger {
      new.push((
        calc.min(an.at(0), bn.at(0)),
        calc.max(an.at(1), bn.at(1)),
      ))
    } else {
      new.push((
        calc.max(an.at(0), bn.at(0)),
        calc.min(an.at(1), bn.at(1)),
      ))
    }
  }
  new
}

#let mat-rotate-x = x => (
  (1, 0, 0),
  (0, calc.cos(x), -calc.sin(x)),
  (0, calc.sin(x), calc.cos(x)),
)

#let mat-rotate-y = y => (
  (calc.cos(y), 0, calc.sin(y)),
  (0, 1, 0),
  (-calc.sin(y), 0, calc.cos(y)),
)

#let mat-rotate-z = z => (
  (calc.cos(z), -calc.sin(z), 0),
  (calc.sin(z), calc.cos(z), 0),
  (0, 0, 1),
)

#let apply-matrices = (v, ..m) => {
  let res = v
  for mat in m.pos() {
    res = mat-mult-vec(mat, res)
  }
  res
}

#let rotate3d = (x, y, z, p) => {
  let v1 = if x != none { rotate-x(x, p) } else { p }
  let v2 = if y != none { rotate-y(y, v1) } else { v1 }
  let v3 = if z != none { rotate-z(z, v2) } else { v2 }
  v3
}

#let perpendicular-2d(line-from, line-to, point, off-x, off-y) = {
  let (pxfrom, pyfrom) = line-from
  let (pxto, pyto) = line-to
  let pm = -(pxfrom - pxto) / (pyfrom - pyto)
  let dir = 1 / calc.sqrt(1 + calc.pow(pm, 2))
  let (tx, ty) = point
  (
    (tx - dir * off-x, ty - pm * dir * off-x).map(i => i * 1%),
    (tx + dir * off-y, ty + pm * dir * off-y).map(i => i * 1%),
  )
}

#let atan2 = (x, y) => if x > 0 {
  calc.atan(y / x).rad()
} else if (x < 0 and y >= 0) {
  calc.atan(y / x).rad() + calc.pi
} else if x < 0 and y < 0 {
  calc.atan(y / x).rad() - calc.pi
} else if x == 0 and y > 0 {
  calc.pi / 2
} else if x == 0 and y < 0 {
  -calc.pi / 2
} else {
  0
}

#let connect-circle-2d(..p) = {
  let c = p
    .pos()
    .reduce(((ax, ay), (x, y)) => (ax + x, ay + y))
    .map(i => float(i / p.pos().len()))
  let angles = p
    .pos()
    .map(((x, y)) => (atan2(float(x) - c.at(0), float(y) - c.at(1)), (x, y)))
  angles.sorted(key: it => it.at(0)).map(it => it.at(1))
}
