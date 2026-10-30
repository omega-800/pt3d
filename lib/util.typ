#import "linalg.typ": *

/// Bin the $(x, y)$ sample points into an `xn` by `yn` 2d histogram on the
/// $z = 0$ plane and returns it as a sampled surface together with the
/// sampled cell coordinates. This is used to build @distribution elements.
///
/// -> dictionary
#let dist3d(
  /// $x$ sample points
  /// -> array
  xp,
  /// $y$ sample points
  /// -> array
  yp,
  /// Number of $x$ buckets
  /// -> int
  xn: 10,
  /// Number of $y$ buckets
  /// -> int
  yn: 10,
  /// Override the ($x$-min, $x$-max) bounds
  /// -> auto | array
  xlim: auto,
  /// Override the ($y$-min, $y$-max) bounds
  /// -> auto | array
  ylim: auto,
) = {
  // TODO: fold init
  let (xmin, xmax) = (calc.min(..xp), calc.max(..xp))
  let (ymin, ymax) = (calc.min(..yp), calc.max(..yp))

  if xlim != auto {
    (xmin, xmax) = xlim
    // xmin = calc.min(xmin, xlim.at(0))
    // xmax = calc.max(xmax, xlim.at(1))
  }
  if ylim != auto {
    (ymin, ymax) = ylim
    // ymin = calc.min(ymin, ylim.at(0))
    // ymax = calc.max(ymax, ylim.at(1))
  }

  let xstep = (xmax - xmin) / (xn)
  let ystep = (ymax - ymin) / (yn)
  let xsteps = range(0, xn).map(x => xmin + xstep * x)
  let ysteps = range(0, yn).map(y => ymin + ystep * y)
  // FIXME: plane pts outer center x,y
  let xres = xsteps.map(x => ysteps.map(_ => x + xstep / 2)).join()
  let yres = xsteps.map(_ => ysteps.map(y => y + ystep / 2)).join()

  let xy = xp.zip(yp)
  // TODO: performance or sth
  let zres = xsteps
    .map(xm => ysteps.map(ym => xy
      .filter(((x, y)) => (
        x >= xm and x < xm + xstep and y >= ym and y < ym + ystep
      ))
      .len()))
    .join()

  // FIXME: rev
  let plane = (xres, yres, zres).map(n => n.rev())
  (
    plane: plane,
    points: plane
      .at(0)
      .zip(plane.at(1), plane.at(2))
      .filter(((x, y, z)) => z == 1),
    xsteps: xsteps,
    ysteps: ysteps,
    xstep: xstep,
    ystep: ystep,
  )
}


/// Checks if a value is a number (int or float)
///
/// -> bool
#let is-num(
  /// Value to check
  /// -> any
  x,
) = type(x) == float or type(x) == int

/// Rescales a 3d line segment so that its 2d projection has the given
/// (rescaled) 2d length. Used internally to position ticks and labels.
///
/// -> array
#let apply-2d-scale-to-3d(
  /// Canvas context, containing `on-canvas` and `map-point-pt`
  /// -> array
  (on-canvas, map-point-pt),
  /// Start and end of the original 3d line
  /// -> array
  (from-3d, to-3d),
  /// Start and end of the projected 2d line
  /// -> array
  (from, to),
  /// Start and end of the rescaled 2d line
  /// -> array
  (from-scaled, to-scaled),
) = {
  let d-orig = distance-vec(from, to)
  let d-start = distance-vec(from, from-scaled)
  let d-end = distance-vec(to, to-scaled)
  let d-3d = distance-vec(from-3d, to-3d)
  // TODO:
  let inv-f = if is-point-on-line-2d((from, to), from-scaled) { 1 } else { -1 }
  let inv-t = if is-point-on-line-2d((from, to), to-scaled) { 1 } else { -1 }

  let (from-3d-scaled, to-3d-scaled) = rescale-line(
    from-3d,
    to-3d,
    (d-end / d-orig) * d-3d, /* * inv-t*/
    from-off: (d-start / d-orig) * d-3d, /* * inv-t*/
  )
  // FIXME: hacky and wrong
  let d-3d-scaled = distance-vec(
    ..(from-3d-scaled, to-3d-scaled).map(on-canvas).map(map-point-pt),
  )
  let d-scaled = distance-vec(from-scaled, to-scaled)

  rescale-line(
    from-3d,
    to-3d,
    (d-end / d-orig) * (d-scaled / d-3d-scaled), /* * inv-t*/
    from-off: (d-start / d-orig) * (d-scaled / d-3d-scaled), /* * inv-t*/
  )
}

/// Groups the elements of an array into a dictionary, where the keys are
/// computed by `fn`.
///
/// -> dictionary
#let group-by(
  /// Elements to group
  /// -> array
  a,
  /// Function that computes the group key of an element
  /// -> function
  fn,
) = a.fold((:), (acc, cur) => {
  let label = fn(cur)
  if label in acc {
    acc.at(label).push(cur)
  } else {
    acc.insert(label, (cur,))
  }
})

/// Checks if a value is a 3d vector in point-normal form, i.e. an array of
/// two 3d vectors.
///
/// -> bool
#let is-point-normal(
  /// Value to check
  /// -> array
  p,
) = (
  type(p) == array
    and p.len() == 2
    and p.at(0).len() == 3
    and p.at(1).len() == 3
)

/// Calculates the midpoint of two position vectors
///
/// ```example
/// #mid-vec((0, 0, 0), (2, 4, 6))
/// ```
///
/// -> vector
#let mid-vec(
  /// Position vector
  /// -> vector
  v,
  /// Position vector
  /// -> vector
  w,
) = v.enumerate().map(((i, n)) => (w.at(i) + n) / 2)

// TODO: generalize
/// Folds a running (min, max) bounding box over a sequence of position
/// vectors.
///
/// -> array
#let minmax-vec(
  /// Current (min, max) bounding box
  /// -> array
  ((xmin, ymin, zmin), (xmax, ymax, zmax)),
  /// New position vector
  /// -> vector
  (x, y, z),
) = (
  (calc.min(xmin, x), calc.min(ymin, y), calc.min(zmin, z)),
  (calc.max(xmax, x), calc.max(ymax, y), calc.max(zmax, z)),
)

// FIXME: float n
/// Places $n$ evenly spaced points between `min` and `max` (inclusive)
///
/// ```example
/// #n-points-on(0, 1, 4)
/// ```
///
/// -> array
#let n-points-on(
  /// Minimum
  /// -> int | float
  min,
  /// Maximum
  /// -> int | float
  max,
  /// Number of points
  /// -> int
  n,
) = if n == 0 { () } else if n == 1 {
  ((max - min) / 2,)
} else {
  range(0, int(n)).map(i => (
    min + i * ((max - min) / (n - 1))
  ))
}

/// Generates an even spaced array of numbers, similar to numpy's `linspace`
///
/// ```example
/// #linspace(0, 10, num: 5)
/// ```
///
/// -> array
#let linspace(
  /// Start of the range (inclusive)
  /// -> int | float
  from,
  /// End of the range
  /// -> int | float
  to,
  /// Number of points, mutually exclusive with `step`
  /// -> auto | int
  num: auto,
  /// Distance between points, mutually exclusive with `num`
  /// -> auto | int | float
  step: auto,
  /// Whether to include the end of the range
  /// -> bool
  include-end: true,
) = {
  assert(num == auto or step == auto, message: "'num' and 'step' are exclusive")
  let n = if num == auto and step == auto {
    50
  } else if num == auto {
    (to - from) / step
  } else {
    num
  }
  // FIXME: check if this broke any internal logic
  let t = if include-end { to } else { to - 1 }
  n-points-on(from, t, n)
}

/// Internal helper used by @meshgrid
///
/// -> array
#let _meshgrid(
  /// Accumulated grid
  /// -> array
  acc,
  /// Remaining dimensions
  /// -> array
  rest,
) = {
  if rest.len() == 0 { acc } else {
    _meshgrid(acc.map(i => rest.at(0).map(j => (..i, j))).join(), rest.slice(1))
  }
}

/// Transposes an array of position-vectors into an array of coordinate lists
///
/// -> array
#let pts-to-dims(
  /// Position vectors
  /// -> array
  pts,
) = {
  range(pts.at(0, default: ()).len()).map(i => pts.map(p => p.at(i)))
}

/// Evaluates an $n$-dimensional grid of points from $n$ coordinate lists
///
/// ```example
/// #meshgrid((0, 1), (0, 1))
/// ```
///
/// -> array
#let meshgrid(
  /// Coordinate lists, one for each dimension
  /// -> array
  ..ls,
  /// Whether to return the points or the transposed dimensions
  /// -> bool
  pts: true,
) = {
  assert(ls.pos().len() > 1, message: "Must provide at least two dimensions")
  // wait why?
  // assert(
  //   ls.pos().map(i => i.len()).dedup().len() == 1,
  //   message: "All dimensions must have same amount of elements",
  // )
  // TODO: optimize
  let res = _meshgrid(ls.pos().at(0).map(i => (i,)), ls.pos().slice(1))
  if pts { res } else { pts-to-dims(res) }
}

/// Evaluates a 2d domain of $(u, v)$ pairs over two intervals. Useful for
/// parametrized elements like @planeplot and @planeparam.
///
/// ```example
/// #domain((0, calc.pi), (0, 1), u-num: 3, v-num: 2)
/// ```
///
/// -> array
#let domain(
  /// ($u$-from, $u$-to) interval
  /// -> array
  (u-from, u-to),
  /// ($v$-from, $v$-to) interval
  /// -> array
  (v-from, v-to),
  /// Number of $u$ points
  /// -> auto | int
  u-num: auto,
  /// $u$ step, mutually exclusive with `u-num`
  /// -> auto | int | float
  u-step: auto,
  /// Whether to include the $u$ end of the interval
  /// -> bool
  u-include-end: true,
  /// Number of $v$ points
  /// -> auto | int
  v-num: auto,
  /// $v$ step, mutually exclusive with `v-num`
  /// -> auto | int | float
  v-step: auto,
  /// Whether to include the $v$ end of the interval
  /// -> bool
  v-include-end: true,
) = (
  linspace(u-from, u-to, num: u-num, step: u-step, include-end: u-include-end)
    .map(u => linspace(
      v-from,
      v-to,
      num: v-num,
      step: v-step,
      include-end: v-include-end,
    ).map(
      v => (u, v),
    ))
    .join()
)

// TODO: remove what isn't used anymore
/// Draws a (2d) polyline through the given $(x, y)$ points
///
/// -> curve
#let path-curve(
  /// Fill of the polygonal area
  /// -> none | auto | color | gradient | tiling
  fill: none,
  /// Fill rule for the polygonal area
  /// -> "non-zero" | "even-odd"
  fill-rule: "non-zero",
  /// Stroke of the line
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: none,
  /// Whether to close the curve
  /// -> bool
  closed: false,
  /// Points as $(x, y)$
  /// -> array
  ..p,
) = {
  let pts = p.pos().slice(1)
  let close = if closed { (curve.close()) } else { () }
  curve(
    fill: fill,
    stroke: stroke,
    fill-rule: fill-rule,
    curve.move(p.pos().at(0)),
    ..pts.map(curve.line),
    ..close,
  )
}

// TODO: remove what isn't used anymore
/// Evaluates $n$ points on each axis of the 3d bounding volume
///
/// -> array
#let n-points-on-cube(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
  ((xmin, xmax), (ymin, ymax), (zmin, zmax)),
  /// Number of points per axis
  /// -> int
  n,
) = n-points-on(xmin, xmax, n).zip(
  n-points-on(ymin, ymax, n),
  n-points-on(zmin, zmax, n),
)

/// Evaluates an $n$ by $n$ grid of $(x, y)$ points within the $x$-$y$ extents
/// of the bounding volume
///
/// -> array
#let x-y-points(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ..
  /// -> array
  ((xmin, xmax), (ymin, ymax), ..),
  /// Grid size
  /// -> int
  n,
) = n-points-on(
  xmax,
  xmin,
  n,
).map(x => n-points-on(ymax, ymin, n).map(y => (x, y)))

/// Applies a color function to a point, or falls back to a default
///
/// -> color | gradient | tiling | none
#let apply-color-fn(
  /// Point
  /// -> vector
  p,
  /// Color function, takes the point
  /// -> none | function
  fn,
  /// Default color
  /// -> color | gradient | tiling | none
  def,
) = if fn != none { fn(..p) } else { def }

/// Extracts the paint from a stroke, or returns the value unchanged
///
/// -> color | gradient | tiling | none
#let stroke-to-paint(
  /// Stroke or paint
  /// -> any
  s,
) = if type(s) == stroke { s.paint } else { s }

/// Coerces a value into a stroke
///
/// -> stroke
#let to-stroke(
  /// Stroke or paint
  /// -> any
  s,
) = if type(s) == stroke { s } else { (paint: s) }

/// Replaces `auto` and `none` with a default value
///
/// -> any
#let or-default(
  /// Value
  /// -> any
  it,
  /// Default value
  /// -> any
  d,
) = if it == auto or it == none { d } else { it }
