#import "linalg.typ": *
#import "util.typ": *

// TODO: vector field?
// TODO: (cubic etc) 3d interpolation on all elems

/// Quiver diagram (vector field)
///
/// ```example
/// #let xs = pt.linspace(-1, 1, num: 5)
/// #let (xs, ys, zs) = pt.meshgrid(xs, xs, xs, pts: false)
/// #pt.diagram(
///   pt.quiver(
///     xs, ys, zs,
///     (x, y, z) => (y / z, -x / z, 0),
///     norm: true,
///     scale: .2,
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
  /// Vector tip, one of `TODO: tips`
  /// -> tip
  tip: ">",
  /// Vector toe, one of `TODO: tips`
  /// -> tip
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
/// #let (rng, xs) = suiji.normal-f(rng, size: 100, scale: 2.5)
/// #let (rng, ys) = suiji.normal-f(rng, size: 100, scale: 2.5)
/// #pt.diagram(
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
  /// Mark for outliers, one of `TODO: marks`
  /// -> none | mark
  mark: ".",
  /// `x` axis sample size
  /// -> int
  xn: 10,
  /// `y` axis sample size
  /// -> int
  yn: 10,
  //// TODO:
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
  /// Mark for intermediary points, one of `TODO: marks`
  /// -> none | mark
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

#let path = (
  stroke: auto,
  label: none,
  stroke-color-fn: none,
  mark: none,
  ..points,
) => {
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

#let polygon = (stroke: auto, fill: none, label: none, ..points) => {
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

#let line = (stroke: auto, label: none, point-normal) => {
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

#let vec = (stroke: auto, label: none, tip: ">", toe: none, ..points) => {
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

#let plane = (
  point-normal,
  stroke: auto,
  fill: auto,
  label: none,
) => {
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

#let planeparam = (
  stroke: auto,
  fill: none,
  steps: auto,
  stroke-color-fn: none,
  fill-color-fn: none,
  label: none,
  fn,
) => (
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
#let tickformat = (
  stroke: auto,
  length: auto,
  offset: auto,
  label-format: tick => text(size: 0.75em)[#calc.round(tick, digits: 2)],
  dir: auto,
) => (
  stroke: stroke,
  length: length,
  offset: offset,
  label-format: label-format,
  dir: dir,
)

#let axisplane = (
  kind: "x",
  position: auto,
  stroke: (paint: black.transparentize(40%), dash: "dotted"),
  fill: none,
  format-ticks: (label-format: none),
  // format-subticks: (:),
  // format-extra-ticks: (:),
) => (
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

#let axisline = (
  kind: "x",
  position: (auto, auto),
  label: auto,
  stroke: black.transparentize(40%),
  label-left: auto,
  tip: none,
  toe: none,
  format-ticks: (:),
  // format-subticks: (:),
  // format-extra-ticks: (:),
) => (
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
// FIXME: wonky
#let axis = (
  order: auto,
  kind: "x",
  instances: (),
  // scale: auto,
  lim: (auto, auto),
  // inverted: false,
  // mirror: auto,
  // offset: auto,
  // exponent: auto,
  // auto-exponent-threshold: 3,
  label: auto,
  // functions: auto,
  hidden: false,
  // filter: (value, distance) => true,
  ticks: auto,
  nticks: auto,
  tick-distance: auto,
  // locate-ticks: auto,
  // subticks: auto,
  // locate-subticks: auto,
  // extra-ticks: (),
  // tick-args: (:),
  // subtick-args: (:),
  ..plots,
) => (
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

#let legend-label(
  format: (it, stroke, fill) => text(size: 0.75em)[#it],
  width: 1em,
  spacing: 0.5em,
  dir: ltr,
) = (
  width: width,
  format: format,
  dir: dir,
  spacing: spacing,
)

#let legend-def(
  position: top + left,
  stroke: black.transparentize(40%),
  fill: black.transparentize(95%),
  dir: ttb,
  spacing: 0.5em,
  inset: 0.25em,
  label: (:),
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
