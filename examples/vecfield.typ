#import "../lib/pt3d.typ" as pt

#let n = 6
#let m = 1
#let r = range(m, n).map(i => (i - n / 2) / 2)
#let xs = (
  r.map(x => r.map(y => r.map(z => x)).join()).join()
)
#let ys = (
  r.map(x => r.map(y => r.map(z => y)).join()).join()
)
#let zs = (
  r.map(x => r.map(y => r.map(z => z)).join()).join()
)
#let ns = range(1, 100).map(i => i / 10)

#let n = 20
#let domain = pt.domain(
  (-calc.pi / 2, calc.pi / 4),
  (-calc.pi * 2, calc.pi / 4),
  u-num: n,
  v-num: n,
)
#pt.diagram(
  width: 15cm,
  height: 15cm,
  rotations: (
    pt.mat-rotate-iso,
    pt.mat-rotate-y(.1),
    pt.mat-rotate-z(.2),
    pt.mat-rotate-x(.1),
  ),
  pt.planeplot(
    num: n,
    domain.map(((u, v)) => .5 * calc.cos(u) * calc.sin(v)),
    domain.map(((u, v)) => .5 * calc.sin(u) * calc.sin(v)),
    domain.map(((u, v)) => .5 * calc.cos(v)),
  ),
  pt.quiver(
    xs,
    ys,
    zs,
    (x, y, z) => {
      let v = (x, y, z)
      let l = pt.length-vec(v)
      if l > 1 {
        pt.scalar-mult-vec(
          -1 / calc.pow(l, 3),
          v,
        )
      } else { v }
    },
    stroke-color-fn: (x, y, z) => {
      let c = 250 * (x, y, z).map(calc.abs).sum() / 3
      pt.rgb-clamp(c, c, c)
    },
    scale: .3,
  ),
)
#let n = 7
#let m = 1
#let r = range(m, n).map(i => (i - n / 2) / 2)
#let xs = (
  r.map(x => r.map(y => r.map(z => x)).join()).join()
)
#let ys = (
  r.map(x => r.map(y => r.map(z => y)).join()).join()
)
#let zs = (
  r.map(x => r.map(y => r.map(z => z)).join()).join()
)
// #let fn = (x, y, z) => (
//   calc.sin(z) * x,
//   calc.sqrt(y * y * x * x),
//   calc.ln(y * y + 1),
// )
#let fn = (x, y, z) => (
  y / z,
  -x / z,
  0,
)

#pt.diagram(
  width: 15cm,
  height: 15cm,
  title: $ f : cases(RR^3 &-> RR^3, vec(x, y, z) &|-> vec(y/z, -x/z, 0)) $,
  rotations: (
    pt.mat-rotate-iso,
    pt.mat-rotate-y(.1),
    pt.mat-rotate-z(.1),
    pt.mat-rotate-x(.4),
  ),
  pt.quiver(
    xs,
    ys,
    zs,
    fn,
    stroke-color-fn: (x, y, z) => {
      let c = (pt.distance-vec((x, y, z), fn(x, y, z)) + 2) * 30
      pt.rgb-clamp(c, 0, 0)
    },
    scale: .1,
  ),
)
