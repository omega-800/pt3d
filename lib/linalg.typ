#let sum-vec = (..v) => (
  v.pos().reduce((acc, cur) => acc.enumerate().map(((i, n)) => (n + cur.at(i))))
)

#let direction-vec = (from, to) => sum-vec(to, from.map(i => -i))

#let length-vec = v => calc.sqrt(v.map(i => i * i).sum())

#let normalize-vec = v => v.map(i => i / length-vec(v))

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

#let dot-product = ((x1, y1, z1), (x2, y2, z2)) => (
  x1 * x2 + y1 * y2 + z1 * z2
)

#let cube-vertices = (((xmin, xmax), (ymin, ymax), (zmin, zmax))) => (
  (xmin, ymin, zmin),
  (xmax, ymin, zmin),
  (xmax, ymax, zmin),
  (xmin, ymax, zmin),
  (xmin, ymin, zmax),
  (xmax, ymin, zmax),
  (xmax, ymax, zmax),
  (xmin, ymax, zmax),
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

#let perpendicular-2d(line-from, line-to, point, off) = {
  let (x, y) = direction-vec(line-from, line-to)
  let (pnx, pny) = normalize-vec((-y, x))
  let (px, py) = point
  let offy = off / 2 * pny
  let offx = off / 2 * pnx
  (
    (px + offx, py + offy),
    (px - offx, py - offy),
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

#let intersection-3d = (
  (x1f, y1f, z1f),
  (x1t, y1t, z1t),
  (x2f, y2f, z2f),
  (x2t, y2t, z2t),
) => {
  let d1 = (x1t - x1f, y1t - y1f, z1t - z1f)
  let d2 = (x2t - x2f, y2t - y2f, z2t - z2f)
  let t = cross-product(d1, d2)
  (
    x1f + t * (x1t - x1f),
    y1f + t * (y1t - y1f),
    z1f + t * (z1t - z1f),
  )
}

#let perpendicular-3d = v => {
  let (x, y, z) = v
  let u = if y == z and x != y {
    (0, 1, 0)
  } else {
    (1, 0, 0)
  }
  cross-product(v, u)
}

#let assert-n-vec = n => assert(
  n.any(i => i != 0),
  message: "Normal vector cannot be zero vector",
)
#let plane-point-normal = (n, p) => {
  assert-n-vec(n)
  (n, p)
}
#let plane-parametric = (p, v, w) => {
  let n = cross-product(v, w)
  assert-n-vec(n)
  (n, p)
}
#let plane-points = (a, b, c) => {
  let n = cross-product(direction-vec(a, b), sum-vec(a, c))
  assert-n-vec(n)
  (n, a)
}
#let plane-coordinate = (x, y, z, d) => {
  assert-n-vec((x, y, z))
  (
    (x, y, z),
    if x != 0 {
      (-d / x, 0, 0)
    } else if y != 0 {
      (0, -d / y, 0)
    } else {
      (0, 0, -d / z)
    },
  )
}
#let plane-hesse = ((x, y, z), d) => plane-coordinate(x, y, z, -d)
#let plane-normal = plane-hesse

#let points-on-plane = (n, p) => {
  let v2 = cross-product((1, 0, 0), n)
  let v3 = cross-product((0, 0, 1), n)
  let p2 = sum-vec(p, v2)
  let p3 = sum-vec(p, v3)
  (p, p2, p3)
}

#let line-parametric = (p, d) => (p, d)
#let line-point-normal = line-parametric
#let line-symmetric = (x, dx, y, dy, z, dz) => ((x, y, z), (dx, dy, dz))
#let line-points = (a, b) => (a, direction-vec(a, b))
