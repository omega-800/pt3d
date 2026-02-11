#import "linalg.typ": *
#import "util.typ": *

// TODO: vector field?
// TODO: marks

#let vertices3d = (
  stroke: auto,
  fill: auto,
  label: none,
  stroke-color-fn: none,
  fill-color-fn: none,
  ..vertices,
) => {
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

// TODO: accept x, y, z functions
// TODO: stroke-color-fn, fill-color-fn
#let lineplot3d = (
  stroke: auto,
  label: none,
  stroke-color-fn: none,
  x,
  y,
  z,
) => {
  assert(
    x.len() == y.len() and x.len() == z.len(),
    message: "x, y and z points must have same length",
  )
  (
    type: "lineplot",
    lineplot: (x, y, z),
    stroke: stroke,
    label: label,
    stroke-color-fn: stroke-color-fn,
  )
}
// TODO: accept x, y, z functions
// TODO: stroke-color-fn, fill-color-fn
#let planeplot3d = (
  stroke: auto,
  fill: auto,
  label: none,
  num: none,
  stroke-color-fn: none,
  fill-color-fn: none,
  x,
  y,
  z,
) => {
  assert(
    x.len() == y.len() and x.len() == z.len(),
    message: "x, y and z points must have same length",
  )
  (
    type: "planeplot",
    planeplot: (x, y, z, num),
    stroke: stroke,
    label: label,
    fill: fill,
    stroke-color-fn: stroke-color-fn,
    fill-color-fn: fill-color-fn,
  )
}


#let path3d = (stroke: auto, label: none, stroke-color-fn: none, ..points) => {
  assert(
    points.pos().len() > 1,
    message: "At least 2 points must be provided",
  )
  (
    type: "path",
    path: points.pos(),
    stroke: stroke,
    label: label,
    stroke-color-fn: stroke-color-fn,
  )
}

#let polygon3d = (stroke: auto, fill: none, label: none, ..points) => {
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

#let line3d = (stroke: auto, label: none, point-normal) => {
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

#let vec3d = (stroke: auto, label: none, tip: ">", toe: none, ..points) => {
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

#let plane3d = (
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

#let lineparam3d = (
  stroke: auto,
  steps: auto,
  stroke-color-fn: none,
  label: none,
  fn,
) => (
  type: "lineparam",
  lineparam: fn,
  stroke: stroke,
  label: label,
  steps: steps,
  stroke-color-fn: stroke-color-fn,
)

#let planeparam3d = (
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

#let tickformat = (
  stroke: auto,
  length: auto,
  offset: auto,
  label-format: tick => text(size: 0.75em)[#calc.round(tick, digits: 2)],
) => (
  stroke: stroke,
  length: length,
  offset: offset,
  label-format: label-format,
)

// TODO: outsource setting default values to ~india~ axis-instance-defaults() fn

#let axisplane3d = (
  kind: "x",
  position: auto,
  label: auto,
  stroke: black.transparentize(40%), // (paint: black.transparentize(40%), dash: "dotted"),
  fill: black.transparentize(95%), // none,
  format-ticks: (label-format: none),
  // format-subticks: (:),
  // format-extra-ticks: (:),
) => (
  type: "axisplane",
  kind: kind,
  label: label,
  position: position,
  stroke: stroke,
  fill: fill,
  format-ticks: if format-ticks == none { none } else {
    tickformat(..format-ticks)
  },
  // format-subticks: format-subticks,
  // format-extra-ticks: format-extra-ticks,
)

#let axisline3d = (
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
#let axis3d = (
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
      axisline3d(kind: kind, label: label),
      axisplane3d(kind: kind, label: label),
    )
  } else {
    // TODO:
    instances.map(i => (
      ..i,
      kind: kind,
      // FIXME: wonky
      // label: if i.type == "axisline" { label } else {
      //   auto
      // }, /* hidden: hidden, */
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
