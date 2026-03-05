#import "../lib/pt3d.typ" as pt
#import "@preview/suiji:0.5.1"
#import "@preview/lilaq:0.5.0" as lq

#let rng = suiji.gen-rng-f(26)
#let (rng, xs) = suiji.normal-f(rng, size: 400, loc: 40, scale: 4)
#let (rng, ys) = suiji.normal-f(rng, size: 400, scale: 4)


#let xlim = (0, 50)
#let ylim = (-10, 10)

// TODO: exponential smoothing
// linear regression splines
// spline interpolation
// scaling / weight

#let dist-dg = pt.diagram.with(
  xaxis: (lim: xlim, nticks: 6),
  yaxis: (lim: ylim, nticks: 5),
  zaxis: (lim: (0, 50), nticks: 6),
)
#let dist = pt.distribution.with(
  fill-color-fn: (x, y, z) => pt.rgb-clamp(
    125,
    0,
    z * 10,
  ),
  stroke: black + 0.25pt,
  mark: m => (pt.marks.at("."))((..m, fill: blue, stroke: none), size: 3pt),
  yn: 10,
  xn: 10,
  xs,
  ys,
)

#grid(
  align: center + horizon,
  columns: 2,
  grid.cell(colspan: 2, lq.diagram(
    title: "2d data points",
    xlim: (0, 52),
    ylim: (-11, 11),
    lq.scatter(xs, ys),
  )),
  dist-dg(
    title: "no interpolation",
    dist(),
  ),
  // dist-dg(
  //   title: "linear interpolation",
  //   dist(),
  // ),
  // dist-dg(
  //   title: "quadratic interpolation",
  //   dist(),
  // ),
  // dist-dg(
  //   title: "cubic interpolation",
  //   dist(),
  // ),
)
