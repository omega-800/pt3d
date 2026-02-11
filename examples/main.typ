#import "../lib/pt3d.typ" as pt

#pt.diagram(
  title: [#sym.Omega],
  width: 9cm,
  height: 9cm,
  legend: (position: bottom, separate: true, dir: ltr),
  rotations: (
    pt.mat-rotate-x(calc.pi / 6),
    pt.mat-rotate-y(-calc.pi / 3),
    pt.mat-rotate-z(0),
  ),

  pt.polygon(
    fill: red.transparentize(70%),
    (3, 0, 3),
    (3, 0, -3),
    (-3, 0, -3),
    (-3, 0, 3),
  ),
  pt.polygon(
    fill: green.transparentize(70%),
    (3, 3, 0),
    (3, -3, 0),
    (-3, -3, 0),
    (-3, 3, 0),
  ),
  pt.polygon(
    fill: blue.transparentize(70%),
    (0, 3, 3),
    (0, 3, -3),
    (0, -3, -3),
    (0, -3, 3),
  ),
  pt.path(
    stroke: red,
    label: "trippy cube",
    (-1, -1, 1),
    (1, -1, 1),
    (1, 1, 1),
    (-1, 1, 1),
    (1, 1, 1),
    (1, 1, -1),
    (1, -1, -1),
    (1, -1, 1),
    (1, -1, -1),
    (1, -1, -1),
    (1, 1, -1),
    (-1, 1, -1),
    (-1, 1, 1),
    (-1, -1, 1),
    (-1, -1, -1),
    (1, -1, -1),
    (-1, -1, -1),
    (-1, 1, -1),
  ),
  pt.vec(
    label: "gradient",
    (3, 3, 3),
    stroke: gradient.linear(yellow, black),
  ),
  pt.vec(
    (2, 2, 1),
    stroke: gradient.linear(yellow, black),
  ),
  pt.vec(
    (1, 1, 0),
    stroke: gradient.linear(yellow, black),
  ),
)
#let xp = pt.linspace(1, 100)
#pt.diagram(
  stroke: blue,
  title: "vecs and lines and such",
  width: 15em,
  height: 9cm,
  xaxis: (instances: (pt.axisplane(),)),
  yaxis: (instances: (pt.axisplane(),)),
  zaxis: (instances: (pt.axisplane(),)),
  legend: (position: top, separate: true),
  pt.lineplot(
    xp,
    xp.map(x => calc.log(x) * 100),
    xp.map(x => (
      calc.log(x) * 100
    )),
    label: "cool plotted line",
  ),
  pt.vec(
    (100, 0, 0),
    (100, 100, 100),
    toe: (stroke, ..x) => text(
      fill: stroke,
    )[O],
    tip: ">",
    label: "vec",
  ),
  pt.vec((50, 100, 100), toe: "|", tip: "|>", label: "vec1"),
  pt.vec((0, 100, 100), (100, 150, 150), toe: "|", tip: ">", label: "vec2"),
)
#let num = 30
#let domain = pt.domain((0, calc.pi), (0, 2 * calc.pi), v-num: num)
#pt.diagram(
  title: [the *\*cone\**],
  width: 30em,
  height: 30em,
  stroke: blue,
  // xaxis: (lim: (-10, 10)),
  // yaxis: (lim: (-10, 10)),
  zaxis: (lim: (1, 3)),
  rotations: (pt.mat-rotate-iso, pt.mat-rotate-x(-calc.pi / 12)),
  pt.planeplot(
    domain.map(((u, v)) => u * calc.sin(v)),
    domain.map(((u, v)) => u * calc.cos(v)),
    domain.map(((u, v)) => u),
    num: num,
    stroke: none,
    fill-color-fn: (x, y, z) => pt.rgb-clamp(50, y * 40 + 50, 50),
  ),
)


#let plane-steps = 20
#let xp = pt.linspace(1, 10)
#let curvy = pt.lineplot(
  xp.map(x => calc.ln(x) * 5 - 10),
  xp.map(x => calc.sin(x) * 5 - 5),
  xp.map(x => calc.cos(x) * 5 + 10),
  stroke-color-fn: (x, y, z) => pt.rgb-clamp(50, 50, z * 30) + 3pt,
)
#let planes = (
  pt.plane(pt.plane-normal((1, 0, 0), -10)),
  pt.plane(pt.plane-normal((0, 1, 0), -10)),
  pt.plane(pt.plane-normal((0, 0, 1), 10)),
)
#let rot = (
  pt.mat-rotate-x(calc.pi / 6),
  pt.mat-rotate-y(-calc.pi / 3),
  pt.mat-rotate-z(0),
)
#grid(
  columns: (auto, auto),
  pt.diagram(
    title: "clip",
    stroke: green,
    rotations: rot,
    xaxis: (lim: (-10, 10)),
    yaxis: (lim: (-10, 10)),
    zaxis: (lim: (0, 10)),
    curvy,
    ..planes,
  ),
  pt.diagram(
    title: "noclip",
    stroke: blue,
    rotations: rot,
    xaxis: (lim: (-10, 10)),
    yaxis: (lim: (-10, 10)),
    zaxis: (lim: (0, 10)),
    noclip: true,
    curvy,
    ..planes,
  ),
)
#pt.diagram(
  title: "test",
  width: 12cm,
  height: 12cm,
  xaxis: (lim: (-2, 5)),
  yaxis: (lim: (-5, 5)),
  zaxis: (lim: (-5, 5)),
  legend: (label: (format: (it, stroke, fill) => text(stroke: fill)[#it])),
  pt.planeparam(
    (x, y) => y * calc.sin(x) - x * calc.cos(y),
    stroke-color-fn: (x, y, z) => pt.rgb-clamp(0, 0, -z * 50 + 120),
    fill-color-fn: (x, y, z) => pt.rgb-clamp(150, 50, -z * 50 + 150),
    steps: plane-steps,
    label: "very awesome plane",
  ),
)

#grid(
  columns: (auto, auto),
  pt.diagram(
    stroke: green,
    xaxis: (lim: (-400, 400)),
    yaxis: (lim: (-400, 400)),
    zaxis: (lim: (-400, 400)),
    title: "something",
    pt.plane(pt.plane-point-normal((4, -7, 2), (0, 1, 2))),
    pt.plane(pt.plane-parametric((0, 1, 2), (3, 2, 1), (-1, 0, 2))),
    pt.plane(pt.plane-coordinate(4, -7, 2, 3)),
    pt.plane(pt.plane-normal((4, -7, 2), -3)),
    pt.plane(pt.plane-hesse(
      pt.normalize-vec((4, -7, 2)),
      -3 / pt.length-vec((4, -7, 2)),
    )),
    pt.vec((4, -7, 2), stroke: red + 9pt),
  ),
  pt.diagram(
    title: "something else",
    stroke: blue,
    pt.plane(pt.plane-normal((1, 2, 4), 1), label: "a blue plane"),
    pt.line(pt.line-parametric((1, 2, 3), (2, 0, 1))),
    pt.line(pt.line-parametric((1, 2, 3), (2, 0, 0))),
    pt.line(pt.line-parametric((1, 2, 3), (2, 0, 2))),
  ),
)

#pt.diagram(
  title: "test",
  width: 12cm,
  height: 12cm,
  stroke: blue,
  xaxis: (lim: (-2, 5)),
  yaxis: (lim: (-2, 5)),
  zaxis: (lim: (-5, 50)),
  pt.planeparam(
    (x, y) => calc.pow(x, 2) + calc.pow(y, 2),
    stroke: blue.transparentize(60%),
    fill: blue.transparentize(60%),
    steps: plane-steps,
  ),
)
#pt.diagram(
  title: "much round very wow",
  width: 30em,
  height: 30em,
  // xaxis: (lim: (-10, 10)),
  // yaxis: (lim: (-10, 10)),
  // zaxis: (lim: (-10, 10)),
  pt.planeplot(
    domain.map(((u, v)) => 6 * calc.cos(u) * calc.sin(v)),
    domain.map(((u, v)) => 6 * calc.sin(u) * calc.sin(v)),
    domain.map(((u, v)) => 6 * calc.cos(v)),
  ),
)
