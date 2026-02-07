#let mid = (v, w) => v.enumerate().map(((i, n)) => (w.at(i) + n) / 2)

#let n-points-on = (min, max, n) => range(0, n + 1).map(i => (
  min + i * ((max - min) / n)
))

// FIXME:
#let linspace = (from, to, num: auto, step: auto, include-end: true) => {
  assert(num == auto or step == auto, message: "'num' and 'auto' are exclusive")
  let n = if num == auto and step == auto {
    50
  } else if num == auto {
    (to - from) / step
  } else {
    num - 1
  }
  let t = if include-end { to } else { to - 1 }
  n-points-on(from, t, n)
}

#let path-curve(
  fill: none,
  fill-rule: "non-zero",
  stroke: none,
  closed: false,
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

#let z-intersection = (z, (x1, y1, z1), (x2, y2, z2)) => {
  let t = (z - z1) / (z2 - z1)
  (x1 + t * (x2 - x1), y1 + t * (y2 - y1), z1 + t * (z2 - z1))
}
// why did i do this exactly?
#let n-points-on-cube = (
  ((xmin, xmax), (ymin, ymax), (zmin, zmax)),
  n,
) => n-points-on(xmin, xmax, n).zip(
  n-points-on(ymin, ymax, n),
  n-points-on(zmin, zmax, n),
)
#let x-y-points = (((xmin, xmax), (ymin, ymax), ..x), n) => n-points-on(
  xmax,
  xmin,
  n,
).map(x => n-points-on(ymax, ymin, n).map(y => (x, y)))

#let apply-color-fn = (p, fn, def) => if fn != none { fn(..p) } else { def }

