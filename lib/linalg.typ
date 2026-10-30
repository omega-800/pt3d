// TODO:
/// Interpolates between $p_1$ and $p_2$ at $t$ with a cubic (catmull-rom)
/// curve through the points $p_0, p_1, p_2, p_3$.
///
/// -> array
#let interpolate-cubic(
  /// Point before $p_1$
  /// -> vector
  p0,
  /// Start point
  /// -> vector
  p1,
  /// End point
  /// -> vector
  p2,
  /// Point after $p_2$
  /// -> vector
  p3,
  /// Interpolation parameter
  /// -> int | float
  t,
) = {
  let interp = ((n0, n1, n2, n3)) => (
    n0
      + (n1 - n0) * t
      + (n2 - 2 * n1 + n0) / 2 * calc.pow(t, 2)
      + (n3 - 3 * n2 + 3 * n1 - n0) / 6 * calc.pow(t, 3)
  )
  p0.zip(p1, p2, p3).map(interp)
}


/// Orthographically projects a 3d point onto the 2d $x$-$y$ canvas
///
/// -> array
#let ortho-proj(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ..
  /// -> array
  ((xmin, xmax), (ymin, ymax), _),
  /// Point to project
  /// -> vector
  (x, y, z),
) = (
  x,
  y,
)

/// Checks if a 2d canvas coordinate is out of bounds
///
/// -> bool
#let out-of-bounds-2d(
  /// 2d canvas coordinate as a fraction of the canvas size
  /// -> ratio | int | float
  x,
) = x > 100% or x < 0%

/// Constructs a function that clamps a 3d point to the given bounding box
///
/// -> function
#let clamp-to-bounds-3d(
  /// $x$-min, $x$-max
  /// -> array
  (xmin, xmax),
  /// $y$-min, $y$-max
  /// -> array
  (ymin, ymax),
  /// $z$-min, $z$-max
  /// -> array
  (zmin, zmax),
) = (
  (x, y, z),
) => (
  calc.clamp(x, xmin, xmax),
  calc.clamp(y, ymin, ymax),
  calc.clamp(z, zmin, zmax),
)

/// Constructs a function that checks if a 3d point is inside the given
/// bounding box
///
/// -> function
#let out-of-bounds-3d(
  /// $x$-min, $x$-max
  /// -> array
  (xmin, xmax),
  /// $y$-min, $y$-max
  /// -> array
  (ymin, ymax),
  /// $z$-min, $z$-max
  /// -> array
  (zmin, zmax),
) = (
  (x, y, z),
) => {
  x < xmin or x > xmax or y < ymin or y > ymax or z < zmin or z > zmax
}

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
/// -> float
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
  // FIXME: division by 0
) = v.map(i => i / length-vec(v))

/// Calculates the distance between two vectors
///
/// ```example
/// #distance-vec((0,1,2), (2,0,1))
/// ```
///
/// -> float
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
/// -> float
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

/// Multiplies a vector with a scalar
///
/// ```example
/// #scalar-mult-vec(2, (1,3,0))
/// ```
///
/// -> vector

#let scalar-mult-vec(
  /// Scalar
  /// -> int | float
  s,
  /// Vector
  /// -> vector
  v,
) = v.map(i => i * s)

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
/// -> float
#let dot-product(
  /// v
  /// -> vector
  v,
  /// w
  /// -> vector
  w,
) = v.zip(w).map(((a, b)) => a * b).sum()

/// The 6 planes of the bounding box in $(n, d)$ point-normal form
///
/// -> array
#let cube-planes(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
  ((xmin, xmax), (ymin, ymax), (zmin, zmax)),
) = (
  ((1, 0, 0), xmin),
  ((-1, 0, 0), -xmax),
  ((0, 1, 0), ymin),
  ((0, -1, 0), -ymax),
  ((0, 0, 1), zmin),
  ((0, 0, -1), -zmax),
)

/// The 8 corner points of the bounding box
///
/// -> array
#let cube-vertices(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
  ((xmin, xmax), (ymin, ymax), (zmin, zmax)),
) = (
  (xmin, ymin, zmin),
  (xmax, ymin, zmin),
  (xmax, ymax, zmin),
  (xmin, ymax, zmin),
  (xmin, ymin, zmax),
  (xmax, ymin, zmax),
  (xmax, ymax, zmax),
  (xmin, ymax, zmax),
)

/// The 12 edges of the bounding box as (start, end) point pairs
///
/// -> array
#let cube-edges(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
  dim,
) = {
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

/// Asserts that a normal vector is not the zero vector
///
/// -> none
#let assert-n-vec(
  /// Normal vector
  /// -> vector
  n,
) = assert(
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
  let n = cross-product(direction-vec(a, b), direction-vec(a, c))
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

/// Returns 3 non-colinear points on the plane in $(n, p)$ point-normal form
///
/// -> array
#let points-on-plane(
  /// Normal vector
  /// -> vector
  n,
  /// Point on plane
  /// -> vector
  p,
) = {
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

/// Calculates the two points of a segment centered on `point` that is
/// perpendicular to a 2d line
///
/// -> array
#let perpendicular-2d(
  /// Point on the line
  /// -> array
  line-from,
  /// Point on the line
  /// -> array
  line-to,
  /// Center of the perpendicular segment
  /// -> array
  point,
  /// Length of the perpendicular segment
  /// -> int | float
  off,
) = {
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

/// Calculates the 2d arctangent of $x$ and $y$ with the correct quadrant
///
/// -> int | float
#let atan2(
  /// x
  /// -> int | float
  x,
  /// y
  /// -> int | float
  y,
) = if x > 0 {
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

/// Orders a list of 2d points clockwise around their centroid
///
/// -> array
#let connect-circle-2d(
  /// 2d points as $(x, y)$
  /// -> array
  ..p,
) = {
  let c = p
    .pos()
    .reduce(((ax, ay), (x, y)) => (ax + x, ay + y))
    .map(i => float(i / p.pos().len()))
  let angles = p
    .pos()
    .map(((x, y)) => (atan2(float(x) - c.at(0), float(y) - c.at(1)), (x, y)))
  angles.sorted(key: it => it.at(0)).map(it => it.at(1))
}

/// Calculates the points where a line in $(p, d)$ parametric form intersects
/// the bounding volume
///
/// -> array
#let intersections-line-dim(
  /// Line in (point, direction) parametric form
  /// -> line
  (p, d),
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
  dim,
) = {
  let out-of-bounds = out-of-bounds-3d(..dim)
  let points = ()
  for (dir, ddim) in dim.enumerate() {
    if d.at(dir) == 0 { continue }
    for m in (0, 1) {
      let t = (ddim.at(m) - p.at(dir)) / d.at(dir)
      let v = sum-vec(p, scalar-mult-vec(t, d))
      if not out-of-bounds(v) {
        points.push(v)
      }
    }
  }
  points
}

/// Checks if a point lies on the inside of a line segment based on
/// distances
///
/// -> bool
#let is-point-on-line-prime(
  /// Line segment as (start, end)
  /// -> array
  (from, to),
  /// Point to check
  /// -> vector
  p,
) = {
  let d-f-t = distance-vec(from, to)
  let d-f-p = distance-vec(from, p)
  let d-p-t = distance-vec(p, to)
  // FIXME: floating point imprecision?
  let tol = d-f-t * 1e-6
  calc.abs(d-f-p + d-p-t - d-f-t) <= tol
}

/// Checks if a point lies on the inside of a line segment based on
/// projections
///
/// -> bool
#let is-point-on-line(
  /// Line segment as (start, end)
  /// -> array
  (from, to),
  /// Point to check
  /// -> vector
  p,
) = {
  let f-t = direction-vec(from, to)
  let f-p = direction-vec(from, p)
  let dot-f-p = dot-product(f-p, f-t)
  let dot-f-f = dot-product(f-t, f-t)
  let dot-f-f-2 = dot-product(f-p, f-p)
  let col = cross-product(f-p, f-t)
  // FIXME: floating point imprecision?
  let tol = (dot-f-f + dot-f-f-2) * 1e-6
  col.all(v => calc.abs(v) <= tol) and 0 <= dot-f-p and dot-f-p <= dot-f-f
}

// TODO:
/// Checks if a 2d point lies on a 2d line segment
///
/// -> bool
#let is-point-on-line-2d(
  /// Line segment as (start, end)
  /// -> array
  (from, to),
  /// Point to check
  /// -> array
  (x, y),
) = {
  let (fx, fy) = from
  let (dx, dy) = (to.at(0) - fx, to.at(1) - fy)
  let (px, py) = (x - fx, y - fy)
  let len2 = dx * dx + dy * dy
  if len2 == 0 {
    return x == fx and y == fy
  }
  let t = (px * dx + py * dy) / len2
  let cross = px * dy - py * dx
  t >= 0 and t <= 1 and calc.abs(cross) <= len2 * 1e-6
}

/// Clips a 3d line segment to the bounding volume. Returns the (start, end)
/// points of the visible part, or `none` if the segment is not visible.
///
/// -> array | none
#let intersection-3d-cube(
  /// Line segment as (start, end)
  /// -> array
  (from, to),
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
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

/// Calculates the intersection point of two 3d lines, or `none` if they
/// are parallel. For skew lines it returns the point of closest approach.
///
/// -> vector | none
#let intersection-3d-lines(
  /// Point on line 1
  /// -> vector
  from1,
  /// Point on line 1
  /// -> vector
  to1,
  /// Point on line 2
  /// -> vector
  from2,
  /// Point on line 2
  /// -> vector
  to2,
) = {
  let d1 = direction-vec(from1, to1)
  let d2 = direction-vec(from2, to2)
  let r = direction-vec(from1, from2)
  let cross-d = cross-product(d1, d2)
  let denom = dot-product(cross-d, cross-d)
  if denom == 0 {
    // Lines are parallel: no unique intersection point.
    return none
  }
  // Point of closest approach of the two lines, which is the intersection
  // if the lines are coplanar.
  let t = dot-product(cross-product(r, d2), cross-d) / denom
  sum-vec(from1, scalar-mult-vec(t, d1))
}

/// Calculates a unit vector that is perpendicular to the given vector
///
/// -> vector
#let perpendicular-3d(
  /// Vector
  /// -> vector
  v,
) = {
  let (x, y, z) = v
  let u = if y == z and x != y {
    (0, 1, 0)
  } else {
    (1, 0, 0)
  }
  cross-product(v, u)
}

/// Rescales a 3d line segment along its direction by the given lengths
///
/// -> array
#let rescale-line(
  /// Start of the line
  /// -> vector
  from,
  /// End of the line
  /// -> vector
  to,
  /// Length from the start to the new end
  /// -> int | float
  to-off,
  /// Length offset from the start to the new start
  /// -> int | float
  from-off: 0,
) = {
  let n = normalize-vec(direction-vec(from, to))
  (
    sum-vec(from, scalar-mult-vec(-from-off, n)),
    sum-vec(from, scalar-mult-vec(to-off, n)),
  )
}
