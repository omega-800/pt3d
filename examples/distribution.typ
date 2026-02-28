#import "../lib/pt3d.typ" as pt
#import "@preview/suiji:0.5.1"
#import "@preview/lilaq:0.5.0" as lq

#let rng = suiji.gen-rng-f(26)
#let (rng, xs) = suiji.normal-f(rng, size: 400, loc: 40, scale: 4)
#let (rng, ys) = suiji.normal-f(rng, size: 400, scale: 4)

#lq.diagram(
  xlim: (0, 52),
  ylim: (-11, 11),
  lq.scatter(xs, ys),
)

#let xlim = (0, 50)
#let ylim = (-10, 10)
#pt.diagram(
  xaxis: (lim: xlim, nticks: 6),
  yaxis: (lim: ylim, nticks: 5),
  zaxis: (lim: (0, 50), nticks: 6),
  pt.distribution(
    interpolate: "cubic",
    fill-color-fn: (x, y, z) => pt.rgb-clamp(
      125,
      0,
      z * 10,
    ),
    stroke: black + 0.25pt,
    yn: 10,
    xn: 10,
    xs,
    ys,
  ),
)
