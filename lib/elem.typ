#let path3d = (stroke: black, ..points) => (
  path: points.pos(),
  stroke: stroke,
)

#let polygon3d = (stroke: black, fill: none, ..points) => (
  polygon: points.pos(),
  stroke: stroke,
  fill: fill,
)

#let line3d = (stroke: black, label: none, ..points) => {
  let pts = points.pos()
  if pts.len() < 2 {
    pts.insert(0, (0, 0, 0))
  }
  (
    line: pts,
    stroke: stroke,
    label: label,
  )
}

#let plane3d = (n, d, stroke: black, fill: black.transparentize(80%)) => (
  plane: (n, d),
  stroke: stroke,
  fill: fill,
)

#let lineparam3d = (
  stroke: black,
  label: none,
  steps: auto,
  stroke-color-fn: none,
  fn,
) => (
  lineparam: fn,
  stroke: stroke,
  label: label,
  steps: steps,
  stroke-color-fn: stroke-color-fn,
)

#let planeparam3d = (
  stroke: black,
  fill: none,
  steps: auto,
  stroke-color-fn: none,
  fill-color-fn: none,
  fn,
) => (
  planeparam: fn,
  stroke-color-fn: stroke-color-fn,
  fill-color-fn: fill-color-fn,
  stroke: stroke,
  fill: fill,
  steps: steps,
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
) => (
  position: if type(position) != array {
    (auto, auto)
  } else { position },
  hidden: hidden,
  stroke: stroke,
)

// FIXME: wonky
#let axis3d = (
  kind: "x",
  label: none,
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
    // tip: auto,
    // toe: auto,
  ),
  ticks: auto,
  nticks: auto,
  subticks: auto,
  tick-distance: auto,
  locate-ticks: auto,
  format-ticks: auto,
  locate-subticks: auto,
  format-subticks: none,
  extra-ticks: (),
  format-extra-ticks: none,
  tick-args: (:),
  subtick-args: (:),
) => (
  axis: true,
  kind: kind,
  label: if label == none { kind } else { label },
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
  format-ticks: format-ticks,
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
  lim: (auto,auto),
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
