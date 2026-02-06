#import "linalg.typ": *
#import "util.typ": *

#let plot3d = (stroke: auto, label: none, x, y, z) => {
  assert(
    x.len() == y.len() and x.len() == z.len(),
    message: "x, y and z points must have same length",
  )
  (
    plot: (x, y, z),
    stroke: stroke,
    label: label,
  )
}

#let path3d = (stroke: auto, label: none, ..points) => {
  assert(
    points.pos().len() > 1,
    message: "At least 2 points must be provided",
  )
  (
    path: points.pos(),
    stroke: stroke,
    label: label,
  )
}

#let polygon3d = (stroke: auto, fill: none, label: none, ..points) => {
  assert(
    points.pos().len() > 2,
    message: "At least 3 points must be provided",
  )
  (
    polygon: points.pos(),
    stroke: stroke,
    fill: fill,
    label: label,
  )
}

#let is-point-normal = p => (
  p.len() == 2 and p.at(0).len() == 3 and p.at(1).len() == 3
)

#let line3d = (stroke: auto, label: none, point-normal) => {
  assert(
    is-point-normal(point-normal.len()),
    message: "Line must be in point-normal form",
  )
  (
    line: point-normal,
    stroke: stroke,
    label: label,
  )
}

#let vec3d = (stroke: auto, label: none, ..points) => {
  let pts = points.pos()
  // TODO: more error handling around the codebase
  assert(pts.len() > 0, message: "Vector must be provided at least one point")
  assert(pts.len() < 3, message: "Vector must have at most two points")
  if pts.len() < 2 {
    pts.insert(0, (0, 0, 0))
  }
  (
    vec: pts,
    stroke: stroke,
    label: label,
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
  planeparam: fn,
  stroke-color-fn: stroke-color-fn,
  fill-color-fn: fill-color-fn,
  stroke: stroke,
  fill: fill,
  steps: steps,
  label: label,
)

#let axisplane3d = (
  position: auto,
  hidden: true,
  stroke: black.transparentize(40%),
  fill: black.transparentize(95%),
) => (position: position, hidden: hidden, stroke: stroke, fill: fill)

#let axisline3d = (
  position: (auto, auto),
  hidden: false,
  stroke: black.transparentize(40%),
  label-left: auto,
) => (
  position: if type(position) != array {
    (auto, auto)
  } else { position },
  hidden: hidden,
  stroke: stroke,
  label-left: label-left,
)

#let tickformat = (
  stroke: black.transparentize(40%),
  length: auto,
  offset: auto,
  label-format: tick => text(size: 0.75em)[#calc.round(tick, digits: 2)],
) => (
  stroke: stroke,
  length: length,
  offset: offset,
  label-format: label-format,
)

// FIXME: wonky
#let axis3d = (
  kind: "x",
  label: auto,
  hidden: false,
  plane: (
    position: auto,
    hidden: true,
    stroke: black.transparentize(40%),
    fill: black.transparentize(95%),
  ),
  line: (
    position: (auto, auto),
    hidden: false,
    stroke: black.transparentize(40%),
    label-left: auto,
    // tip: auto,
    // toe: auto,
  ),
  ticks: auto,
  nticks: auto,
  subticks: auto,
  tick-distance: auto,
  locate-ticks: auto,
  format-ticks: (:),
  locate-subticks: auto,
  format-subticks: (:),
  extra-ticks: (),
  format-extra-ticks: (:),
  // tick-args: (:),
  // subtick-args: (:),
) => (
  axis: true,
  kind: kind,
  label: if label == auto { kind } else { label },
  hidden: hidden,
  plane: axisplane3d(..plane),
  line: axisline3d(..line),
  ticks: ticks,
  nticks: nticks,
  // subticks: subticks,
  tick-distance: tick-distance,
  // offset: offset,
  // exponent: exponent,
  // auto-exponent-threshold: auto-exponent-threshold,
  // locate-ticks: locate-ticks,
  format-ticks: tickformat(..format-ticks),
  // locate-subticks: locate-subticks,
  // format-subticks: format-subticks,
  // extra-ticks: extra-ticks,
  // format-extra-ticks: format-extra-ticks,
  // tick-args: tick-args,
  // subtick-args: subtick-args,
)

#let axis = (
  order: auto,
  kind: "x",
  instances: (),
  scale: auto,
  lim: (auto, auto),
  inverted: false,
  mirror: auto,
  offset: auto,
  exponent: auto,
  auto-exponent-threshold: 3,
  functions: auto,
  hidden: false,
  filter: (value, distance) => true,
  ..plots,
) => (
  order: order,
  axis: true,
  kind: kind,
  instances: if instances.len() == 0 {
    (axis3d(kind: kind, plane: (hidden: false)),)
  } else {
    instances.map(i => axis3d(hidden: hidden, kind: kind, ..i))
  },
  // scale: scale,
  lim: lim,
  // inverted: inverted,
  // mirror: mirror,
  // functions: functions,
  hidden: hidden,
  // filter: filter,
)

#let legend-def(
  position: top + left,
  label-format: it => text(size: 0.75em)[#it],
  stroke: black.transparentize(40%),
  fill: black.transparentize(95%),
  dir: ttb,
) = (
  position: position,
  label-format: label-format,
  stroke: stroke,
  fill: fill,
  dir: dir,
)
