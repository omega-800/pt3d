#import "../lib/pt3d.typ" as pt3d

#pt3d.diagram(
  title: "test",
  width: 12cm,
  height: 12cm,
  xaxis: (lim: (-2, 5)),
  yaxis: (lim: (-5, 5)),
  zaxis: (lim: (-5, 5)),
  pt3d.planeparam3d(
    (x, y) => y * calc.sin(x) - x * calc.cos(y),
    stroke: blue,
    fill: blue.transparentize(90%),
    stroke-color-fn: (x, y, z) => pt3d.rgb-clamp(0, 0, -z * 50 + 120),
    fill-color-fn: (x, y, z) => pt3d.rgb-clamp(150, 50, -z * 50 + 150),
    steps: 50,
  ),
)
#pt3d.diagram(
  title: "test",
  width: 12cm,
  height: 12cm,
  xaxis: (lim: (-2, 5)),
  yaxis: (lim: (-2, 5)),
  zaxis: (lim: (-5, 50)),
  pt3d.plane3d((-2, 20, 3), 5, fill: red.transparentize(60%)),
  pt3d.planeparam3d(
    (x, y) => calc.pow(x, 2) + calc.pow(y, 2),
    stroke: blue.transparentize(60%),
    fill: blue.transparentize(60%),
    steps: 50,
  ),
)
#pt3d.diagram(
  width: 10cm,
  height: 10cm,
  xaxis: (
    lim: (-10, 10),
    instances: (
      (plane: (hidden: false, position: -10)),
    ),
  ),
  yaxis: (
    lim: (-10, 10),
    instances: (
      (plane: (hidden: false, position: -10)),
    ),
  ),
  zaxis: (
    lim: (-10, 10),
    instances: (
      (plane: (hidden: false, position: 10)),
    ),
  ),
  pt3d.plane3d((3, -2, 3), 10, fill: blue.transparentize(50%)),
)
#pt3d.diagram(
  title: [STUFF #sym.Omega],
  // fill: blue,
  xaxis: (
    lim: (-3, 3),
    // FIXME:
    // instances: ((plane: (hidden: true), line: (hidden: true)),),
  ),
  yaxis: (lim: (-3, 3), instances: ((plane: (hidden: true)),)),
  zaxis: (lim: (-3, 3), instances: ((plane: (hidden: true)),)),
  width: 9cm,
  height: 9cm,
  rotations: (
    pt3d.mat-rotate-x(calc.pi / 6),
    pt3d.mat-rotate-y(calc.pi / 6),
    pt3d.mat-rotate-z(0),
  ),

  pt3d.polygon3d(
    fill: red.transparentize(70%),
    (3, 0, 3),
    (3, 0, -3),
    (-3, 0, -3),
    (-3, 0, 3),
  ),
  pt3d.polygon3d(
    fill: green.transparentize(70%),
    (3, 3, 0),
    (3, -3, 0),
    (-3, -3, 0),
    (-3, 3, 0),
  ),
  pt3d.polygon3d(
    fill: blue.transparentize(70%),
    (0, 3, 3),
    (0, 3, -3),
    (0, -3, -3),
    (0, -3, 3),
  ),
  pt3d.path3d(
    stroke: red,
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
  pt3d.line3d(
    label: "1",
    (3, 3, 3),
    stroke: gradient.linear(yellow, black),
  ),
  pt3d.line3d(
    label: "2",
    (2, 2, 1),
    stroke: gradient.linear(yellow, black),
  ),
  pt3d.line3d(
    label: "3",
    (1, 1, 0),
    stroke: gradient.linear(yellow, black),
  ),
)
