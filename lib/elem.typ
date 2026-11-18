#import "linalg.typ": *
#import "util.typ": *

// TODO: vector field?
// TODO: (cubic etc) 3d interpolation on all elems

/// Quiver diagram (vector field)
///
/// ```example
/// #let xs = pt.linspace(-1, 1, num: 4)
/// #let (xs, ys, zs) = pt.meshgrid(xs, xs, xs, pts: false)
/// #pt.diagram(
///   pt.quiver(
///     xs, ys, zs,
///     (x, y, z) => (y / z, -x / z, 0),
///     norm: true,
///     scale: .3,
///   )
/// )
/// ```
#let quiver(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @quiver.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Fill color function, defaults to @quiver.fill
  /// -> none | function
  fill-color-fn: none,
  /// Vector tip, one of the @marks
  /// -> none | str | function
  tip: ">",
  /// Vector toe, one of the @marks
  /// -> none | str | function
  toe: none,
  /// Scale
  /// -> int | float
  scale: 1,
  /// If vectors should be normalized
  /// -> bool
  norm: false,
  /// `x` data points
  /// -> array
  xs,
  /// `y` data points
  /// -> array
  ys,
  /// `z` data points
  /// -> array
  zs,
  /// Direction function
  /// -> function
  dir,
) = {
  (
    type: "quiver",
    stroke: stroke,
    fill: fill,
    label: label,
    stroke-color-fn: stroke-color-fn,
    fill-color-fn: fill-color-fn,
    tip: tip,
    toe: toe,
    scale: scale,
    xs: xs,
    ys: ys,
    zs: zs,
    dir: dir,
    norm: norm,
  )
}

/// Scatter points
///
/// ```example
/// #let xs = pt.linspace(-1, 1, num: 3)
/// #let (xs, ys, zs) = pt.meshgrid(xs, xs, xs, pts: false)
/// #pt.diagram(
///   pt.scatter(
///     xs, ys, zs,
///   )
/// )
/// ```
#let scatter(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @quiver.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Fill color function, defaults to @quiver.fill
  /// -> none | function
  fill-color-fn: none,
  /// One of the @marks
  /// -> none | str | function
  mark: "o",
  /// Scale
  /// -> int | float
  scale: 1,
  /// `x` data points
  /// -> array
  xs,
  /// `y` data points
  /// -> array
  ys,
  /// `z` data points
  /// -> array
  zs,
) = {
  (
    type: "scatter",
    stroke: stroke,
    fill: fill,
    label: label,
    stroke-color-fn: stroke-color-fn,
    fill-color-fn: fill-color-fn,
    // TODO:
    scale: scale,
    mark: mark,
    xs: xs,
    ys: ys,
    zs: zs,
  )
}

// TODO: w/ bars n stuff
// #let histogram = (
//   stroke: auto,
//   fill: auto,
//   label: none,
//   stroke-color-fn: none,
//   fill-color-fn: none,
//   xn: 10,
//   yn: 10,
//   xs,
//   ys,
// ) => {
//   (
//     type: "histogram",
//     xs: xs,
//     ys: ys,
//     xn: xn,
//     yn: yn,
//     mark: mark,
//     label: label,
//     stroke: stroke,
//     fill: fill,
//     stroke-color-fn: stroke-color-fn,
//     fill-color-fn: fill-color-fn,
//     interpolate: interpolate,
//   )
// }

/// Histogram (distribution)
///
/// ```example
/// #let rng = suiji.gen-rng-f(26)
/// #let (rng, xs) = suiji.normal-f(rng, size: 200, scale: 2)
/// #let (rng, ys) = suiji.normal-f(rng, size: 200, scale: 2)
/// #pt.diagram(
///   xaxis: (lim: (-7, 7)),
///   yaxis: (lim: (-7, 7)),
///   pt.distribution(
///     xs, ys,
///   )
/// )
/// ```
#let distribution(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @distribution.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Fill color function, defaults to @distribution.fill
  /// -> none | function
  fill-color-fn: none,
  /// Mark for outliers, one of the @marks
  /// -> none | str | function
  mark: ".",
  /// `x` axis sample size
  /// -> int
  xn: 10,
  /// `y` axis sample size
  /// -> int
  yn: 10,
  /// TODO:
  /// -> none | array
  interpolate: none,
  /// `x` data points
  /// -> array
  xs,
  /// `y` data points
  /// -> array
  ys,
) = {
  (
    type: "distribution",
    xs: xs,
    ys: ys,
    xn: xn,
    yn: yn,
    mark: mark,
    label: label,
    stroke: stroke,
    fill: fill,
    stroke-color-fn: stroke-color-fn,
    fill-color-fn: fill-color-fn,
    interpolate: interpolate,
  )
}

/// Vertices
///
/// ```example
/// #pt.diagram(
///   pt.vertices(
///     fill: red.transparentize(80%),
///     stroke: purple,
///     ..pt.heart()
///   )
/// )
/// ```
#let vertices(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @vertices.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Fill color function, defaults to @vertices.fill
  /// -> none | function
  fill-color-fn: none,
  /// Vertices as $(x,y,z)$
  /// -> array
  ..vertices,
) = {
  (
    type: "vertices",
    vertices: vertices.pos(),
    stroke: stroke,
    label: label,
    fill: fill,
    stroke-color-fn: stroke-color-fn,
    fill-color-fn: fill-color-fn,
  )
}


/// Plotted line
///
/// ```example
/// #let xs = pt.linspace(0,calc.pi * 3)
/// #pt.diagram(
///    pt.lineplot(
///      xs.map(x => calc.cos(x) * 5),
///      xs,
///      xs.map(x => calc.sin(x) * 10),
///    )
///  )
/// ```
#let lineplot(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @lineplot.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Mark for intermediary points, one of the @marks
  /// -> none | str | function
  mark: ".",
  /// `x` data points
  /// -> array
  xs,
  /// `y` data points
  /// -> array
  ys,
  /// `z` data points
  /// -> array
  zs,
) = {
  assert(
    xs.len() == ys.len() and xs.len() == zs.len(),
    message: "x, y and z points must have same length",
  )
  (
    type: "lineplot",
    mark: mark,
    // TODO: unfold
    lineplot: (xs, ys, zs),
    stroke: stroke,
    label: label,
    stroke-color-fn: stroke-color-fn,
  )
}

/// Plotted surface
///
/// ```example
///  #let num = 20
///  #let domain = pt.domain((0, calc.pi), (0, 2 * calc.pi), v-num: num, u-num: num)
///  #diagram(
///    pt.planeplot(
///      domain.map(((u, v)) => u * calc.sin(v)),
///      domain.map(((u, v)) => u * calc.cos(v)),
///      domain.map(((u, v)) => u * 2),
///      num: num,
///    ),
///  )
/// ```
#let planeplot(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @planeplot.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Fill color function, defaults to @planeplot.fill
  /// -> none | function
  fill-color-fn: none,
  /// TODO:
  /// -> none | int
  num: none,
  /// `x` data points
  /// -> array
  xs,
  /// `y` data points
  /// -> array
  ys,
  /// `z` data points
  /// -> array
  zs,
) = {
  assert(
    xs.len() == ys.len() and xs.len() == zs.len(),
    message: "x, y and z points must have same length",
  )
  (
    type: "planeplot",
    // TODO: unfold
    planeplot: (xs, ys, zs, num),
    stroke: stroke,
    label: label,
    fill: fill,
    stroke-color-fn: stroke-color-fn,
    fill-color-fn: fill-color-fn,
  )
}

/// Path along points
///
/// ```example
///  #diagram(
///    pt.path(
///      (0,1,1), (1,2,1), (3,3,3),
///      (3,2,0), (3,2,1), (2,0,0)
///    ),
///  )
/// ```
#let path(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Stroke color function, defaults to @path.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Mark for intermediary points, one of the @marks
  /// -> none | str | function
  mark: none,
  /// Points as $(x,y,z)$
  /// -> array
  ..points,
) = {
  assert(
    points.pos().len() > 1,
    message: "At least 2 points must be provided",
  )
  (
    type: "path",
    path: points.pos(),
    mark: mark,
    stroke: stroke,
    label: label,
    stroke-color-fn: stroke-color-fn,
  )
}

// TODO: polygon color-fn
// TODO: polygon marks

/// Polygon along points
///
/// ```example
///  #diagram(
///    pt.polygon(
///      (0,1,1), (1,2,1), (3,3,3),
///      (3,2,0), (3,2,1), (2,0,0)
///    ),
///  )
/// ```
#let polygon(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Points as $(x,y,z)$
  /// -> array
  ..points,
) = {
  assert(
    points.pos().len() > 2,
    message: "At least 3 points must be provided",
  )
  (
    type: "polygon",
    polygon: points.pos(),
    stroke: stroke,
    fill: fill,
    label: label,
  )
}

/// Renders line in point-normal form. The line can be constructed with
/// @line-parametric, @line-point-normal, @line-symmetric or @line-points.
///
/// ```example
/// #diagram(
///   pt.line(
///     pt.line-points((-1, -1, -1), (1, 1, 1)),
///   ),
/// )
/// ```
#let line(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Point-normal form of the line $(p, d)$
  /// -> array
  point-normal,
) = {
  assert(
    is-point-normal(point-normal),
    message: "Line must be in point-normal form",
  )
  (
    type: "line",
    line: point-normal,
    stroke: stroke,
    label: label,
  )
}

/// Vector with tip and toe marks
///
/// ```example
/// #pt.diagram(
///   pt.vec(
///     (0, 0, 0),
///     (4, 3, 6),
///     stroke: red,
///     tip: "o",
///     toe: "o",
///   ),
/// )
/// ```
///
/// -> dictionary
#let vec(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Label
  /// -> none | content
  label: none,
  /// Vector tip, one of the @marks
  /// -> none | str | function
  tip: ">",
  /// Vector toe, one of the @marks
  /// -> none | str | function
  toe: none,
  /// Points as $(x,y,z)$, at most two. If only one point is given, the
  /// origin is used as the start.
  /// -> array
  ..points,
) = {
  let pts = points.pos()
  // TODO: more error handling around the codebase
  assert(pts.len() > 0, message: "Vector must be provided at least one point")
  assert(pts.len() < 3, message: "Vector must have at most two points")
  if pts.len() < 2 {
    pts.insert(0, (0, 0, 0))
  }
  (
    type: "vec",
    vec: pts,
    stroke: stroke,
    label: label,
    tip: tip,
    toe: toe,
  )
}

/// Plane in point-normal form
///
/// ```example
/// #pt.diagram(
///   xaxis: (lim: (0, 3)),
///   pt.plane(
///     pt.plane-normal((1, 0, 0), calc.pi / 3),
///     fill: black.transparentize(85%),
///   ),
/// )
/// ```
///
/// -> dictionary
#let plane(
  /// Point-normal form of the plane $(n, p)$, can be constructed with
  /// @plane-point-normal, @plane-parametric, @plane-points,
  /// @plane-coordinate, @plane-hesse or @plane-normal
  /// -> plane
  point-normal,
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to the $n$th color-cycle entry
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Label
  /// -> none | content
  label: none,
) = {
  assert(
    is-point-normal(point-normal),
    message: "Plane must be in point-normal form",
  )
  (
    type: "plane",
    plane: point-normal,
    stroke: stroke,
    fill: fill,
    label: label,
  )
}

// #let lineparam = (
//   stroke: auto,
//   steps: auto,
//   stroke-color-fn: none,
//   mark: none,
//   label: none,
//   fn,
// ) => (
//   type: "lineparam",
//   lineparam: fn,
//   stroke: stroke,
//   label: label,
//   steps: steps,
//   stroke-color-fn: stroke-color-fn,
//   mark: mark,
// )

/// Parametrized plane $z = f(x, y)$
///
/// ```example
/// #pt.diagram(
///   xaxis: (lim: (-1.5, 1.5)),
///   yaxis: (lim: (-1.5, 1.5)),
///   zaxis: (lim: (0, 1)),
///   pt.planeparam(
///     (x, y) => {
///       let z = 1 - x * x - y * y
///       if z < 0 { z } else { calc.sqrt(z) }
///     },
///     steps: 20,
///   ),
/// )
/// ```
///
/// -> dictionary
#let planeparam(
  /// Stroke, defaults to the $n$th color-cycle entry
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Fill, defaults to none
  /// -> auto | none | color | gradient | tiling
  fill: none,
  /// Number of samples per axis
  /// -> auto | int
  steps: auto,
  /// Stroke color function, defaults to @planeparam.stroke
  /// -> none | function
  stroke-color-fn: none,
  /// Fill color function, defaults to @planeparam.fill
  /// -> none | function
  fill-color-fn: none,
  /// Label
  /// -> none | content
  label: none,
  /// The function $f(x, y) = z$
  /// -> function
  fn,
) = (
  type: "planeparam",
  planeparam: fn,
  stroke-color-fn: stroke-color-fn,
  fill-color-fn: fill-color-fn,
  stroke: stroke,
  fill: fill,
  steps: steps,
  label: label,
)

// TODO: http://lilaq.org/docs/tutorials/ticks#custom-tick-formatting
/// Format for the ticks of an @axisline or an @axisplane. The same
/// parameters can be given directly as the `format-ticks` argument, e.g.
/// `pt.axisline(format-ticks: (length: 30pt))`.
///
/// -> dictionary
#let tickformat(
  /// Stroke of the tick marks, `auto` uses the stroke of the axis
  /// -> auto | none | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Length of the tick marks, `auto` uses a sensible default
  /// -> auto | length
  length: auto,
  /// Offset of the tick marks from the axis line, `auto` uses a
  /// sensible default
  /// -> auto | length
  offset: auto,
  /// Function that formats the tick value into a label. `none` hides the
  /// label.
  /// -> none | function
  label-format: tick => text(size: 0.75em)[#calc.round(tick, digits: 2)],
  /// Direction the tick marks are drawn in
  /// -> auto | str
  dir: auto,
) = (
  stroke: stroke,
  length: length,
  offset: offset,
  label-format: label-format,
  dir: dir,
)

// TODO: format-subticks: (:), format-extra-ticks: (:),
/// A plane perpendicular to one axis that visualizes the "back wall" of the
/// bounding volume, optionally with a grid of ticks. Used as an @axis
/// instance.
///
/// ```example
/// #pt.diagram(
///   stroke: blue,
///   xaxis: (instances: (pt.axisplane(),)),
///   yaxis: (instances: (pt.axisplane(),)),
///   zaxis: (instances: (pt.axisplane(),)),
/// )
/// ```
///
/// -> dictionary
#let axisplane(
  /// Axis kind, one of `x`, `y` and `z`. Set automatically by @axis.
  /// -> str
  kind: "x",
  /// Position of the plane on the axis, `auto` places it on the far side
  /// of the bounding volume
  /// -> auto | int | float
  position: auto,
  /// Stroke of the plane outline
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: (paint: black.transparentize(40%), dash: "dotted"),
  /// Fill of the plane
  /// -> auto | none | color | gradient | tiling
  fill: none,
  /// Tick format as a @tickformat dictionary, or a list of them for the
  /// grid lines. `none` disables the ticks.
  /// -> none | dictionary | array
  format-ticks: (label-format: none),
) = (
  type: "axisplane",
  kind: kind,
  position: position,
  stroke: stroke,
  fill: fill,
  format-ticks: if format-ticks == none {
    none
  } else if type(format-ticks) == array {
    format-ticks.map(f => tickformat(..f))
  } else {
    (tickformat(..format-ticks), tickformat(..format-ticks))
  },
  // format-subticks: format-subticks,
  // format-extra-ticks: format-extra-ticks,
)

// TODO: format-subticks: (:), format-extra-ticks: (:),
/// A line along one axis with ticks and a label. Used as an @axis instance.
///
/// ```example
/// #pt.diagram(
///   stroke: blue,
///   xaxis: (
///     instances: (
///       pt.axisline(format-ticks: (length: 30pt, offset: 15pt)),
///     ),
///   ),
///   yaxis: (instances: (pt.axisline(),)),
///   zaxis: (instances: (pt.axisline(),)),
/// )
/// ```
///
/// -> dictionary
#let axisline(
  /// Axis kind, one of `x`, `y` and `z`. Set automatically by @axis.
  /// -> str
  kind: "x",
  /// (start, end) positions of the line on the other two axes, `auto`
  /// spans the whole bounding volume
  /// -> array
  position: (auto, auto),
  /// Label of the axis, `auto` uses the axis letter
  /// -> auto | none | content
  label: auto,
  /// Stroke of the axis line
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: black.transparentize(40%),
  /// Whether the label is drawn on the left side, `auto` decides based on
  /// the position
  /// -> auto | bool
  label-left: auto,
  /// Vector tip at the end of the axis, one of the @marks
  /// -> none | str | function
  tip: none,
  /// Vector toe at the start of the axis, one of the @marks
  /// -> none | str | function
  toe: none,
  /// Tick format as a @tickformat dictionary. `none` disables the ticks.
  /// -> none | dictionary
  format-ticks: (:),
) = (
  type: "axisline",
  kind: kind,
  label: label,
  position: position,
  stroke: stroke,
  label-left: label-left,
  tip: tip,
  toe: toe,
  format-ticks: if format-ticks == none { none } else {
    tickformat(..format-ticks)
  },
  // format-subticks: format-subticks,
  // format-extra-ticks: format-extra-ticks,
)

// TODO: clean this up
// TODO: scale: auto, inverted: false, mirror: auto, offset: auto, exponent: auto,
// auto-exponent-threshold: 3, functions: auto, filter: (value, distance) => true,
// locate-ticks: auto, subticks: auto, locate-subticks: auto, extra-ticks: (),
// tick-args: (:), subtick-args: (:),
// FIXME: wonky
/// An axis of the diagram, consisting of a label, extent limit and a set of
/// instances (@axisline and @axisplane). Pass parameter dictionaries for
/// `xaxis`, `yaxis` and `zaxis` of @diagram, or use this function directly.
///
/// ```example
/// #pt.diagram(
///   xaxis: pt.axis(nticks: 8, label: "t"),
///   yaxis: pt.axis(lim: (-5, 5)),
///   pt.lineplot(
///     pt.linspace(0, 10, num: 20),
///     pt.linspace(-5, 5, num: 20),
///     pt.linspace(-2, 2, num: 20),
///   ),
/// )
/// ```
///
/// -> dictionary
#let axis(
  /// Axis order for depth sorting, `auto` sorts by default
  /// -> auto | int
  order: auto,
  /// Axis kind, one of `x`, `y` and `z`. Set automatically by @diagram.
  /// -> str
  kind: "x",
  /// Axis instances, defaults to an @axisline and an @axisplane
  /// -> array
  instances: (),
  /// Axis limit as (`min`, `max`), `auto` spans the data
  /// -> array
  lim: (auto, auto),
  /// Label of the axis, `auto` uses the axis letter
  /// -> auto | none | content
  label: auto,
  /// Whether to hide the axis
  /// -> bool
  hidden: false,
  /// Tick positions, `auto` calculates them from `nticks`
  /// -> auto | array
  ticks: auto,
  /// Number of ticks, `auto` calculates them from the available space
  /// -> auto | int
  nticks: auto,
  /// Minimum distance between the ticks
  /// -> auto | length
  tick-distance: auto,
  /// Other axis parameters
  /// -> dictionary
  ..plots,
) = (
  order: order,
  kind: kind,
  type: "axis",
  instances: if instances.len() == 0 {
    (
      axisline(kind: kind, label: label),
      axisplane(kind: kind),
    )
  } else {
    instances.map(i => (
      ..i,
      kind: kind,
    ))
  },
  // scale: scale,
  lim: lim,
  // inverted: inverted,
  // mirror: mirror,
  // functions: functions,
  hidden: hidden,
  // filter: filter,
  ticks: ticks,
  nticks: nticks,
  // subticks: subticks,
  tick-distance: tick-distance,
  // offset: offset,
  // exponent: exponent,
  // auto-exponent-threshold: auto-exponent-threshold,
  // locate-ticks: locate-ticks,
  // locate-subticks: locate-subticks,
  // extra-ticks: extra-ticks,
  // tick-args: tick-args,
  // subtick-args: subtick-args,
)

/// Format of the legend labels of a @diagram
///
/// -> dictionary
#let legend-label(
  /// Function that renders the label: `format(element-label, stroke, fill)`
  /// -> function
  format: (it, stroke, fill) => text(size: 0.75em)[#it],
  /// Width of the line/area preview of a legend entry
  /// -> length
  width: 1em,
  /// Spacing between the preview and the label
  /// -> length
  spacing: 0.5em,
  /// Direction of the legend entries
  /// -> direction
  dir: ltr,
) = (
  width: width,
  format: format,
  dir: dir,
  spacing: spacing,
)

/// Parameters of the legend of a @diagram. Every element with a `label`
/// gets a legend entry.
///
/// -> dictionary
#let legend-def(
  /// Position of the legend inside the canvas, e.g. `top + left`
  /// -> location
  position: top + left,
  /// Stroke of the legend box
  /// -> none | auto | length | color | gradient | stroke | tiling | dictionary
  stroke: black.transparentize(40%),
  /// Fill of the legend box
  /// -> auto | none | color | gradient | tiling
  fill: black.transparentize(95%),
  /// Direction of the legend entries
  /// -> direction
  dir: ttb,
  /// Spacing between the legend entries
  /// -> length
  spacing: 0.5em,
  /// Inset of the legend box
  /// -> length
  inset: 0.25em,
  /// Legend label format, see @legend-label
  /// -> dictionary
  label: (:),
  /// Whether the legend should be placed next to the plot instead of
  /// inside the canvas
  /// -> bool
  separate: false,
) = (
  position: position,
  label: legend-label(..label),
  stroke: stroke,
  fill: fill,
  dir: dir,
  spacing: spacing,
  inset: inset,
  separate: separate,
)
