#import "../lib/pt3d.typ" as pt

#grid(
  columns: (auto, auto),
  pt.diagram(
    stroke: green,
    xaxis: (lim: (-400, 400)),
    yaxis: (lim: (-400, 400)),
    zaxis: (lim: (-400, 400)),
    title: "something",
    pt.plane3d(pt.plane-point-normal((4, -7, 2), (0, 1, 2))),
    pt.plane3d(pt.plane-parametric((0, 1, 2), (3, 2, 1), (-1, 0, 2))),
    pt.plane3d(pt.plane-coordinate(4, -7, 2, 3)),
    pt.plane3d(pt.plane-normal((4, -7, 2), -3)),
    pt.plane3d(pt.plane-hesse(
      pt.normalize-vec((4, -7, 2)),
      -3 / pt.length-vec((4, -7, 2)),
    )),
    pt.vec3d((4, -7, 2), stroke: red + 9pt),
  ),
  pt.diagram(
    title: "something else",
    stroke: blue,
    pt.plane3d(pt.plane-normal((1, 2, 4), 1), label: "a blue plane"),
    pt.line3d(pt.line-parametric((1, 2, 3), (2, 0, 1))),
    pt.line3d(pt.line-parametric((1, 2, 3), (2, 0, 0))),
    pt.line3d(pt.line-parametric((1, 2, 3), (2, 0, 2))),
  ),
)

#pt.diagram(
  title: "test",
  width: 12cm,
  height: 12cm,
  xaxis: (lim: (-2, 5)),
  yaxis: (lim: (-5, 5)),
  zaxis: (lim: (-5, 5)),
  pt.planeparam3d(
    (x, y) => y * calc.sin(x) - x * calc.cos(y),
    stroke-color-fn: (x, y, z) => pt.rgb-clamp(0, 0, -z * 50 + 120),
    fill-color-fn: (x, y, z) => pt.rgb-clamp(150, 50, -z * 50 + 150),
    steps: 50,
    label: "very awesome plane",
  ),
)
#pt.diagram(
  title: "test",
  width: 12cm,
  height: 12cm,
  xaxis: (lim: (-2, 5)),
  yaxis: (lim: (-2, 5)),
  zaxis: (lim: (-5, 50)),
  pt.planeparam3d(
    (x, y) => calc.pow(x, 2) + calc.pow(y, 2),
    stroke: blue.transparentize(60%),
    fill: blue.transparentize(60%),
    steps: 50,
  ),
)
#pt.diagram(
  title: [#sym.Omega],
  width: 9cm,
  height: 9cm,
  rotations: (
    pt.mat-rotate-x(calc.pi / 6),
    pt.mat-rotate-y(-calc.pi / 3),
    pt.mat-rotate-z(0),
  ),

  pt.polygon3d(
    fill: red.transparentize(70%),
    (3, 0, 3),
    (3, 0, -3),
    (-3, 0, -3),
    (-3, 0, 3),
  ),
  pt.polygon3d(
    fill: green.transparentize(70%),
    (3, 3, 0),
    (3, -3, 0),
    (-3, -3, 0),
    (-3, 3, 0),
  ),
  pt.polygon3d(
    fill: blue.transparentize(70%),
    (0, 3, 3),
    (0, 3, -3),
    (0, -3, -3),
    (0, -3, 3),
  ),
  pt.path3d(
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
  pt.vec3d(
    label: "gradient",
    (3, 3, 3),
    stroke: gradient.linear(yellow, black),
  ),
  pt.vec3d(
    (2, 2, 1),
    stroke: gradient.linear(yellow, black),
  ),
  pt.vec3d(
    (1, 1, 0),
    stroke: gradient.linear(yellow, black),
  ),
)
#let xp = pt.linspace(1, 100)
#pt.diagram(
  title: "vecs and lines and such",
  width: 15em,
  height: 30em,
  xaxis: (instances: ((line: (position: (200, 200)), plane: (hidden: false)),)),
  yaxis: (instances: ((line: (position: (100, 200)), plane: (hidden: false)),)),
  zaxis: (instances: ((line: (position: (100, 0)), plane: (hidden: false)),)),
  legend: (position: bottom + left),
  pt.lineplot3d(
    xp,
    xp.map(x => calc.log(x) * 100),
    xp.map(x => (
      calc.log(x) * 100
    )),
    label: "cool plotted line",
  ),
  pt.vec3d(
    (100, 0, 0),
    (100, 100, 100),
    toe: (stroke, ..x) => text(
      fill: stroke,
    )[O],
    tip: ">",
    label: "vec",
  ),
  pt.vec3d((50, 100, 100), toe: "|", tip: "|>", label: "vec1"),
  pt.vec3d((0, 100, 100), (100, 150, 150), toe: "|", tip: ">", label: "vec2"),
)
#let udomain = pt.linspace(0, calc.pi + 1)
#let vdomain = pt.linspace(0, 2 * calc.pi + 1)
#let domain = udomain.map(u => vdomain.map(v => (u, v))).join()
#pt.diagram(
  title: [the *\*cone\**],
  width: 30em,
  height: 30em,
  // xaxis: (lim: (-10, 10)),
  // yaxis: (lim: (-10, 10)),
  // zaxis: (lim: (-10, 10)),
  rotations: (pt.mat-rotate-iso, pt.mat-rotate-x(-calc.pi / 12)),
  pt.planeplot3d(
    domain.map(((u, v)) => u * calc.sin(v)),
    domain.map(((u, v)) => u * calc.cos(v)),
    domain.map(((u, v)) => u),
  ),
),
)

#pt.diagram(
  title: "much round very wow",
  width: 30em,
  height: 30em,
  // xaxis: (lim: (-10, 10)),
  // yaxis: (lim: (-10, 10)),
  // zaxis: (lim: (-10, 10)),
  pt.planeplot3d(
    domain.map(((u, v)) => 6 * calc.cos(u) * calc.sin(v)),
    domain.map(((u, v)) => 6 * calc.sin(u) * calc.sin(v)),
    domain.map(((u, v)) => 6 * calc.cos(v)),
  ),
)
