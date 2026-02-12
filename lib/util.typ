#import "linalg.typ": *

#let is-num = x => type(x) == float or type(x) == int

#let apply-2d-scale-to-3d = (
  (from-3d, to-3d),
  (from, to),
  (from-scaled, to-scaled),
) => {
  let d-orig = distance-vec(from, to)
  let d-start = distance-vec(from, from-scaled)
  let d-end = distance-vec(to, to-scaled)
  let d-3d = distance-vec(from-3d, to-3d)

  // FIXME: this was done by guessing
  // TODO: do this properly
  rescale-line(
    from-3d,
    to-3d,
    // FIXME: fr
    0,
    // (d-end / d-orig) * d-3d,
    from-off: (d-start / d-orig) * d-3d,
  )
}

#let group-by = (a, fn) => a.fold((:), (acc, cur) => {
  let label = fn(cur)
  if label in acc {
    acc.at(label).push(cur)
  } else {
    acc.insert(label, (cur,))
  }
})

#let is-point-normal = p => (
  type(p) == array
    and p.len() == 2
    and p.at(0).len() == 3
    and p.at(1).len() == 3
)

#let mid-vec = (v, w) => v.enumerate().map(((i, n)) => (w.at(i) + n) / 2)

// TODO: generalize
#let minmax-vec = (((xmin, ymin, zmin), (xmax, ymax, zmax)), (x, y, z)) => (
  (calc.min(xmin, x), calc.min(ymin, y), calc.min(zmin, z)),
  (calc.max(xmax, x), calc.max(ymax, y), calc.max(zmax, z)),
)

#let n-points-on = (min, max, n) => range(0, n + 1).map(i => (
  min + i * ((max - min) / n)
))

// FIXME: num + 1
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

#let domain = (
  (u-from, u-to),
  (v-from, v-to),
  u-num: auto,
  u-step: auto,
  u-include-end: true,
  v-num: auto,
  v-step: auto,
  v-include-end: true,
) => (
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

// TODO: remove what isn't used anymore
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
