#let ortho-proj = (((xmin, xmax), (ymin, ymax), _), (x, y, z)) => (
  // FIXME: huh.
  x,
  y,
  // (2 * x - xmax - xmin) / (xmax - xmin),
  // (2 * y - ymax - ymin) / (ymax - ymin),
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

/// Adds an arbitrary amount of vectors
///
/// ```example
/// #sum-vec((0,1,2), (2,0,1), (-1, 0, 1))
/// ```
///
/// -> vector
#let sum-vec(
  /// The vectors to sum up
  /// -> vectors
  ..v,
) = (
  v.pos().reduce((acc, cur) => acc.enumerate().map(((i, n)) => (n + cur.at(i))))
)

/// Calculates the direction vector of two vectors
///
/// ```example
/// #direction-vec((0,1,2), (2,0,1))
/// ```
///
/// -> vector
#let direction-vec(
  /// Start vector
  /// -> vector
  from,
  /// End vector
  /// -> vector
  to,
) = sum-vec(to, from.map(i => -i))

/// Calculates the length of a vector
///
/// ```example
/// #length-vec((0,3,4))
/// ```
///
/// -> vector
#let length-vec(
  /// Vector
  /// -> vector
  v,
) = calc.sqrt(v.map(i => i * i).sum())

/// Normalizes a vector
///
/// ```example
/// #normalize-vec((0,3,4))
/// ```
///
/// -> vector
#let normalize-vec(
  /// Vector
  /// -> vector
  v,
) = v.map(i => i / length-vec(v))

/// Calculates the distance between two vectors
///
/// ```example
/// #distance-vec((0,1,2), (2,0,1))
/// ```
///
/// -> vector
#let distance-vec(
  /// Start vector
  /// -> vector
  from,
  /// End vector
  /// -> vector
  to,
) = length-vec(direction-vec(to, from))

/// Calculates the squared distance between two vectors
///
/// ```example
/// #distance-vec-squared((0,1,2), (2,0,1))
/// ```
///
/// -> vector
#let distance-vec-squared(
  /// Start vector
  /// -> vector
  from,
  /// End vector
  /// -> vector
  to,
) = (
  direction-vec(to, from).map(i => i * i).sum()
)

/// Multiplies a $RR^(3 times 3)$ matrix with a $RR^3$ vector
///
/// ```example
/// #mat-mult-vec((
///     (1,0,0),
///     (0,1,0),
///     (0,0,1)
///   ), (2,0,1))
/// ```
///
/// -> vector
#let mat-mult-vec(
  /// Matrix
  /// -> matrix
  ((a, b, c), (d, e, f), (g, h, i)),
  /// Vector
  /// -> vector
  (x, y, z),
) = (
  a * x + b * y + c * z,
  d * x + e * y + f * z,
  g * x + h * y + i * z,
)

/// Calculates the cross product of two vectors
///
/// ```example
/// #cross-product((1,3,2), (2,0,1))
/// ```
///
/// -> vector
#let cross-product(
  /// w
  /// -> vector
  (x1, y1, z1),
  /// v
  /// -> vector
  (x2, y2, z2),
) = (
  y1 * z2 - z1 * y2,
  z1 * x2 - x1 * z2,
  x1 * y2 - y1 * x2,
)

/// Calculates the dot product of two vectors
///
/// ```example
/// #dot-product((1,3,2), (2,0,1))
/// ```
///
/// -> vector
#let dot-product = (
  /// w
  /// -> vector
  (x1, y1, z1),
  /// v
  /// -> vector
  (x2, y2, z2),
) => (
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

/// Constructs plane from point normal form
///
/// -> plane
#let plane-point-normal(
  /// Normal vector
  /// -> vector
  n,
  /// Point on plane
  /// -> vector
  p,
) = {
  assert-n-vec(n)
  (n, p)
}
/// Constructs plane from parametric form
///
/// -> plane
#let plane-parametric(
  /// Point on plane
  /// -> vector
  p,
  /// Non-colinear vector 1
  /// -> vector
  v,
  /// Non-colinear vector 2
  /// -> vector
  w,
) = {
  let n = cross-product(v, w)
  assert-n-vec(n)
  (n, p)
}
/// Constructs plane from given points
///
/// -> plane
#let plane-points(
  /// Point 1
  /// -> vector
  a,
  /// Point 2
  /// -> vector
  b,
  /// Point 3
  /// -> vector
  c,
) = {
  let n = cross-product(direction-vec(a, b), sum-vec(a, c))
  assert-n-vec(n)
  (n, a)
}
/// Constructs plane from coordinate form
///
/// -> plane
#let plane-coordinate(
  /// x
  /// -> int | float
  x,
  /// y
  /// -> int | float
  y,
  /// z
  /// -> int | float
  z,
  /// Distance
  /// -> int | float
  d,
) = {
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
/// Constructs plane from hesse form
///
/// -> plane
#let plane-hesse(
  /// Normal vector
  /// -> vector
  (x, y, z),
  /// Distance
  /// -> int | float
  d,
) = plane-coordinate(x, y, z, -d)

/// Constructs plane from normal form (alias for `plane-hesse`)
///
/// -> plane
#let plane-normal = plane-hesse

#let points-on-plane = (n, p) => {
  let v2 = cross-product((1, 0, 0), n)
  let v3 = cross-product((0, 0, 1), n)
  let p2 = sum-vec(p, v2)
  let p3 = sum-vec(p, v3)
  (p, p2, p3)
}

/// Constructs line from parametric form
///
/// -> line
#let line-parametric(
  /// Point on line
  /// -> vector
  p,
  /// Direction vector
  /// -> vector
  d,
) = (p, d)

/// Constructs line from point-normal form (alias for `line-parametric`)
///
/// -> line
#let line-point-normal = line-parametric

/// Constructs line from symmetric form
///
/// -> line
#let line-symmetric(
  /// x
  /// -> int | float
  x,
  /// x-intercept
  /// -> int | float
  dx,
  /// y
  /// -> int | float
  y,
  /// y-intercept
  /// -> int | float
  dy,
  /// z
  /// -> int | float
  z,
  /// z-intercept
  /// -> int | float
  dz,
) = ((x, y, z), (dx, dy, dz))
/// Constructs line from given points
///
/// -> line
#let line-points(
  /// Point 1
  /// -> vector
  a,
  /// Point 2
  /// -> vector
  b,
) = (a, direction-vec(a, b))

/// Isometric rotation matrix
///
/// -> matrix
#let mat-rotate-iso = (
  (calc.sqrt(3), 0, -calc.sqrt(3)),
  (-1, 2, -1),
  (calc.sqrt(2), calc.sqrt(2), calc.sqrt(2)),
).map(r => r.map(i => i / calc.sqrt(6)))

/// Constructs a rotation matrix in the x direction
///
/// -> matrix
#let mat-rotate-x(
  /// Amount to rotate by
  /// -> int | float
  x,
) = (
  (1, 0, 0),
  (0, calc.cos(x), -calc.sin(x)),
  (0, calc.sin(x), calc.cos(x)),
)

/// Constructs a rotation matrix in the y direction
///
/// -> matrix
#let mat-rotate-y(
  /// Amount to rotate by
  /// -> int | float
  y,
) = (
  (calc.cos(y), 0, calc.sin(y)),
  (0, 1, 0),
  (-calc.sin(y), 0, calc.cos(y)),
)

/// Constructs a rotation matrix in the y direction
///
/// -> matrix
#let mat-rotate-z(
  /// Amount to rotate by
  /// -> int | float
  z,
) = (
  (calc.cos(z), -calc.sin(z), 0),
  (calc.sin(z), calc.cos(z), 0),
  (0, 0, 1),
)

/// Multiplies a $RR^3$ vector with $RR^(3 times 3)$ matrices
///
/// -> matrix
#let apply-matrices(
  /// Vector
  /// -> vector
  v,
  /// Matrices
  /// -> matrices
  ..m,
) = {
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

#let rescale-line = (from, to, to-off, from-off: 0) => {
  let n = normalize-vec(direction-vec(from, to))
  (
    sum-vec(from, n.map(i => -i * from-off)),
    sum-vec(from, n.map(i => i * to-off)),
  )
}
