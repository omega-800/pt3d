#let path3d = (stroke: none, ..points) => (
  path: points.pos(),
  stroke: stroke,
)
#let polygon3d = (stroke: none, fill: none, ..points) => (
  polygon: points.pos(),
  stroke: stroke,
  fill: fill,
)
#let line3d = (stroke: none, label: none, ..points) => {
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
#let plane3d = (n, d, stroke: none, fill: none) => (
  plane: (n, d),
  stroke: stroke,
  fill: fill,
)

#let axis3d = (
  kind: "x",
  position: 0,
  stroke: black,
  fill: black.transparentize(90%),
  label: none,
  plane: (
    hidden: true,
  ),
  line: (
    hidden: false,
    // tip: auto,
    // toe: auto,
  ),
) => (
  position: position,
  label: if label == none { kind } else { label },
  stroke: stroke,
  fill: fill,
  plane: plane,
  line: line,
)

#let axis = (
  kind: "x",
  instances: (),
  scale: auto,
  lim: auto,
  inverted: false,
  mirror: auto,
  ticks: auto,
  subticks: auto,
  tick-distance: auto,
  offset: auto,
  exponent: auto,
  auto-exponent-threshold: 3,
  locate-ticks: auto,
  format-ticks: auto,
  locate-subticks: auto,
  format-subticks: none,
  extra-ticks: (),
  format-extra-ticks: none,
  tick-args: (:),
  subtick-args: (:),
  functions: auto,
  hidden: false,
  filter: (value, distance) => true,
  ..plots,
) => (
  axis: true,
  kind: kind,
  instances: if instances.len() == 0 { (axis3d(kind: kind),) } else {
    instances.map(i => axis3d(kind: kind, ..i))
  },
  // scale: scale,
  lim: if lim == auto { (-1, 1) } else { lim },
  // inverted: inverted,
  // mirror: mirror,
  ticks: ticks,
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
  // functions: functions,
  hidden: hidden,
  // filter: filter,
)
