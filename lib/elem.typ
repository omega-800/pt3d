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

#let plane3d = (n, d, stroke: black, fill: none) => (
  plane: (n, d),
  stroke: stroke,
  fill: fill,
)

#let lineparam3d = (stroke: black, label: none, steps: auto, fn) => (
  lineparam: fn,
  stroke: stroke,
  label: label,
  steps: steps
)

#let planeparam3d = (stroke: black, fill: none, steps: auto, color-fn: () => black, fn) => (
  planeparam: fn,
  color-fn: color-fn,
  stroke: stroke,
  fill: fill,
  steps: steps
)

#let axis3d = (
  kind: "x",
  stroke: black,
  fill: black.transparentize(90%),
  label: none,
  hidden: false,
  plane: (
    position: 0,
    hidden: true,
  ),
  line: (
    position: (0, 0),
    hidden: false,
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
  kind: kind,
  label: if label == none { kind } else { label },
  hidden: hidden,
  stroke: stroke,
  fill: fill,
  plane: plane,
  line: (
    ..line,
    position: if not "position" in line or type(line.position) != array {
      (0, 0)
    } else { line.position },
  ),
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
  lim: auto,
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
  instances: if instances.len() == 0 { (axis3d(kind: kind),) } else {
    instances.map(i => axis3d(hidden: hidden, kind: kind, ..i))
  },
  // scale: scale,
  lim: if lim == auto { (-1, 1) } else { lim },
  // inverted: inverted,
  // mirror: mirror,
  // functions: functions,
  hidden: hidden,
  // filter: filter,
)
