#import "util.typ": *
#import "eval.typ": *
#import "elem.typ": axis

/// Computes the offset and scale that are needed so that the given 2d
/// points all fit inside the unit square (0%-100%) of the canvas
///
/// -> array
#let overflow-correction(
  /// 2d canvas coordinates as fractions of the canvas size
  /// -> array
  ns,
) = {
  let s = ns.filter(out-of-bounds-2d).sorted()
  let high = calc.max(s.last(default: 100%), 100%)
  let low = calc.min(s.first(default: 0%), 0%)
  let span = high - low
  (
    -low / span * 100%,
    (100% / span) * 100%,
  )
}

/// Constructs a function that measures the 2d distance between two 3d
/// points on the canvas
///
/// -> function
#let measure-3d-pt(
  /// Function that projects a 3d point to the 2d canvas
  /// -> function
  on-canvas,
  /// Function that maps a 2d canvas point to a 2d point in pt
  /// -> function
  map-point-pt,
) = (
  from,
  to,
) => distance-vec(
  ..(from, to).map(on-canvas).map(map-point-pt),
)

/// Constructs a linear rescaling function of 2d points:
/// `(x, y)` becomes `(x * xscale + xo, y * yscale + yo)`
///
/// -> function
#let rescale(
  /// (offset, scale) for the x coordinate
  /// -> array
  (xo, xscale),
  /// (offset, scale) for the y coordinate
  /// -> array
  (yo, yscale),
) = (
  (x, y),
) => {
  (x * xscale + xo, y * yscale + yo)
}

/// Constructs a function that orders a 3d point by the axis ordering,
/// flipping the z axis so that the axes are sorted by depth
///
/// -> function
#let order-axes(
  /// Axis ordering as (x-order, y-order, z-order)
  /// -> array
  (xo, yo, zo),
) = (
  (x, y, z),
) => (
  ((x, xo), (y, yo), (-z, zo)).sorted(key: it => it.at(1)).map(it => it.at(0))
)

/// Constructs the canvas projection function: transforms, rotates,
/// orthographically projects and rescales a 3d point onto the 2d canvas
///
/// -> function
#let canvas(
  /// Bounding box as ($x$-min, $x$-max), ($y$-min, $y$-max), ($z$-min, $z$-max)
  /// -> array
  dim,
  /// Axis reordering transformation
  /// -> function
  transform-fn,
  /// Rotation by the axis rotations
  /// -> function
  rotate-fn,
  /// Rescaling to the canvas size
  /// -> function
  scale-fn,
) = p => scale-fn(
  ortho-proj(
    dim,
    rotate-fn(transform-fn(p)),
  ),
)

// FIXME: wonky
/// Resolves a bounding axis limit against the data extents. `lim` entries
/// that are not numbers are replaced by `min`/`max` (or -1/1 if those are
/// not available). Degenerate limits (min == max) are expanded by 1.
///
/// -> array
#let def-lim(
  /// Minimum of the data
  /// -> auto | int | float
  min,
  /// Maximum of the data
  /// -> auto | int | float
  max,
  /// Axis limit as (`min`, `max`)
  /// -> array
  lim: (-1, 1),
  /// Other axis parameters (unused)
  /// -> dictionary
  ..x,
) = {
  let def = (i, def) => if is-num(i) { i } else { def }
  let lim = (def(def(lim.at(0), min), 1), def(def(lim.at(1), max), -1))
  if lim.at(0) == lim.at(1) {
    lim.at(0) -= 1
    lim.at(1) += 1
  }
  lim
}

// TODO: make the stuff that's badly implemented better

/// Constructs the canvas context of a @diagram: evaluates the bounding box
/// and the axes, and computes the projection functions. Returns the
/// (title-offset, ctx) pair.
///
/// -> array
#let gen-ctx(
  /// Title of the diagram, or `none`
  /// -> auto | none | content
  title,
  /// (width, height) of the canvas
  /// -> array
  (width, height),
  /// The 3 axis parameter dictionaries
  /// -> array
  (xaxis, yaxis, zaxis),
  /// Rotation matrices
  /// -> array
  rotations,
  /// The elements of the plot
  /// -> array
  children,
  /// Whether to disable clipping of the elements
  /// -> bool
  noclip,
) = {
  let xas = axis(..xaxis, kind: "x")
  let yas = axis(..yaxis, kind: "y")
  let zas = axis(..zaxis, kind: "z")

  let ((xmin, ymin, zmin), (xmax, ymax, zmax)) = eval-min-bounds(
    (xas, yas, zas),
    ..children,
  )

  let (ox, oz, oy) = (xas, zas, yas)
    .enumerate()
    .map(((i, a)) => if a.order != auto { a.order } else { i })
  let a-order = (ox, oy, oz)

  let xlim = def-lim(xmin, xmax, ..xas)
  let ylim = def-lim(ymin, ymax, ..yas)
  let zlim = def-lim(zmin, zmax, ..zas)

  let dim = (xlim, ylim, zlim)

  let transform-canvas = order-axes(a-order)
  let rotate-canvas = v => apply-matrices(v, ..rotations)

  // TODO: only include rendered points
  let plot-extremes = cube-vertices(dim).map(canvas(
    dim,
    transform-canvas,
    rotate-canvas,
    x => x.map(i => i * 100%),
  ))
  let on-canvas = canvas(
    dim,
    transform-canvas,
    rotate-canvas,
    rescale(
      overflow-correction(plot-extremes.map(((x, y)) => x)),
      overflow-correction(plot-extremes.map(((x, y)) => y)),
    ),
  )

  let offset = 0pt
  if title != none {
    // huh why does measuring block provide scuffed dimensions
    offset = measure(title).height + 10pt
  }

  let canvas-dim = (
    width: width.to-absolute().pt() * 1pt,
    height: (height.to-absolute().pt() - offset.pt()) * 1pt,
  )
  let ctx = (
    canvas-dim: canvas-dim,
    on-canvas: on-canvas,
    map-point-pt: ((x, y)) => (
      (x * canvas-dim.width) / 1pt,
      (y * canvas-dim.height) / 1pt,
    ),
    dim: dim,
    intersection-canvas: (from, to) => intersection-3d-cube((from, to), dim),
    out-of-bounds: out-of-bounds-3d(..dim),
    clamp-to-bounds: clamp-to-bounds-3d(..dim),
    rotate-canvas: rotate-canvas,
    noclip: noclip,
  )
  ctx.measure-3d-pt = measure-3d-pt(ctx.on-canvas, ctx.map-point-pt)
  let (xas, yas, zas) = axes-defaults(xas, yas, zas, ctx)
  ctx.axes = (xas, yas, zas)

  // FIXME: still bad bad code
  let axes-eval = ctx.axes.map(i => eval-axis-points(ctx, i)).join()
  let plot-extremes = (..axes-eval, ..cube-vertices(dim)).map(canvas(
    dim,
    transform-canvas,
    rotate-canvas,
    x => x.map(i => i * 100%),
  ))
  ctx.on-canvas = canvas(
    ctx.dim,
    transform-canvas,
    rotate-canvas,
    rescale(
      overflow-correction(plot-extremes.map(((x, y)) => x)),
      overflow-correction(plot-extremes.map(((x, y)) => y)),
    ),
  )
  ctx.measure-3d-pt = measure-3d-pt(ctx.on-canvas, ctx.map-point-pt)
  ctx.pt-to-ratio = p => {
    let (width, height) = ctx.canvas-dim
    p
      .map(i => i.to-absolute().pt())
      .zip((width, height).map(i => i.to-absolute().pt()))
      .map(((i, d)) => (i / d) * 100%)
  }

  (offset, ctx)
}
