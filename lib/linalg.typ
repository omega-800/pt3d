#let ortho-proj = (((xmin, xmax), (ymin, ymax), _), (x, y, z)) => (
  (2 * x - xmax - xmin) / (xmax - xmin),
  (2 * y - ymax - ymin) / (ymax - ymin),
)

#let out-of-bounds-2d = x => x > 100% or x < 0%

#let clamp-to-bounds-3d = ((xmin, xmax), (ymin, ymax), (zmin, zmax)) => (
  (x, y, z),
) => (
  calc.clamp(x, xmin, xmax),
  calc.clamp(y, ymin, ymax),
  calc.clamp(z, zmin, zmax),
)

#let out-of-bounds-3d = ((xmin, xmax), (ymin, ymax), (zmin, zmax)) => (
  (x, y, z),
) => x < xmin or x > xmax or y < ymin or y > ymax or z < zmin or z > zmax

#let sum-vec = (..v) => (
  v.pos().reduce((acc, cur) => acc.enumerate().map(((i, n)) => (n + cur.at(i))))
)

#let direction-vec = (from, to) => sum-vec(to, from.map(i => -i))

#let length-vec = v => calc.sqrt(v.map(i => i * i).sum())

#let normalize-vec = v => v.map(i => i / length-vec(v))

#let distance-vec = (from, to) => length-vec(direction-vec(to, from))

#let distance-vec-squared = (from, to) => (
  direction-vec(to, from).map(i => i * i).sum()
)

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

#let cube-planes = (((xmin, xmax), (ymin, ymax), (zmin, zmax))) => (
  ((1, 0, 0), xmin),
  ((-1, 0, 0), xmax),
  ((0, 1, 0), ymin),
  ((0, -1, 0), ymax),
  ((0, 0, 1), zmin),
  ((0, 0, -1), zmax),
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

#let mat-rotate-iso = (
  (calc.sqrt(3), 0, -calc.sqrt(3)),
  (-1, 2, -1),
  (calc.sqrt(2), calc.sqrt(2), calc.sqrt(2)),
).map(r => r.map(i => i / calc.sqrt(6)))

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

#let intersections-line-dim((p, d), dim) = {
  let out-of-bounds = out-of-bounds-3d(..dim)
  let points = ()
  for (dir, ddim) in dim.enumerate() {
    if d.at(dir) == 0 { continue }
    for m in (0, 1) {
      let t = (ddim.at(m) - p.at(dir)) / d.at(dir)
      let v = sum-vec(p, d.map(i => i * t))
      if not out-of-bounds(v) {
        points.push(v)
      }
    }
  }
  points
}
#let is-point-on-line-prime((from, to), p) = {
  let d-f-t = distance-vec(from, to)
  let d-f-p = distance-vec(from, p)
  let d-p-t = distance-vec(p, to)
  // FIXME: floating point imprecision?
  // d-f-t == d-f-p + d-p-t + 1
  d-f-t <= d-f-p + d-p-t + 1 and d-f-t >= d-f-p + d-p-t - 1
}

#let is-point-on-line((from, to), p) = {
  let f-t = direction-vec(from, to)
  let f-p = direction-vec(from, p)
  let dot-f-p = dot-product(f-p, f-t)
  let dot-f-f = dot-product(f-t, f-t)
  let s-c = cross-product(f-p, f-t).sum()
  // FIXME: floating point imprecision?
  // s-c == 0 and 0 <= dot-f-p and dot-f-p <= dot-f-f
  s-c <= 1 and s-c >= -1 and 0 <= dot-f-p and dot-f-p <= dot-f-f
}
// FIXME: wtf typst, i thought you were like rust
// TODO: add return statements where values have to be returned

#let intersection-3d-cube(
  (from, to),
  dim,
) = {
  let out-of-bounds = out-of-bounds-3d(..dim)
  let from-out = out-of-bounds(from)
  let to-out = out-of-bounds(to)
  if not from-out and not to-out {
    return (from, to)
  }
  let intersections = intersections-line-dim(line-points(from, to), dim).filter(
    p => is-point-on-line((from, to), p),
  )
  if intersections.len() == 0 {
    none
  } else if from-out and to-out {
    // FIXME:
    (intersections.at(0), intersections.at(1, default: intersections.at(0)))
  } else if from-out {
    (intersections.find(p => p != to), to)
  } else if to-out {
    (from, intersections.find(p => p != from))
  }
}

// FIXME: wrong
#let intersection-3d-cube-prime = (
  (inside, outside),
  dim,
) => {
  let dir = direction-vec(inside, outside)
  let ts = ()
  for (i, d) in dim.enumerate() {
    if dir.at(i) == 0 {
      continue
    }
    for m in d {
      let t = (m - inside.at(i)) / dir.at(i)
      if t < 0 or t > 1 {
        continue
      }
      let i2 = calc.rem(i + 1, 3)
      let i3 = calc.rem(i + 2, 3)
      let inter1 = inside.at(i2) + t * dir.at(i2)
      let inter2 = inside.at(i3) + t * dir.at(i3)
      let (min1, max1) = dim.at(i2)
      let (min2, max2) = dim.at(i3)
      if (
        min1 <= inter1 and inter1 <= max1 and min2 <= inter2 and inter2 <= max2
      ) {
        ts.push(t)
      }
    }
  }
  let intert = calc.min(..ts)
  (0, 1, 2).map(i => inside.at(i) + intert * dir.at(i))
}

#let intersection-3d-lines = (
  from1,
  to1,
  from2,
  to2,
) => {
  let d1 = distance-vec(from1, to1)
  let d2 = distance-vec(from2, to2)
  let t = cross-product(d1, d2)
  sum-vec(from1, d1.map(i => i * t))
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
