#import "../lib/pt3d.typ" as pt3d

#let v2 = pt3d.cross-product((1, 0, 0), (4, -7, 2))
#let v3 = pt3d.cross-product((0, 0, 1), (4, -7, 2))
#let p1 = (0, 1, 2)
#let p2 = pt3d.sum-vec(p1, v2)
#let p3 = pt3d.sum-vec(p1, v3)

#let xp = pt3d.linspace(1, 100)
#pt3d.diagram(
  stroke: blue,
  width: 15em,
  height: 15em,
  xaxis: (instances: ((line: (position: (200, 200)), plane: (hidden: false)),)),
  yaxis: (instances: ((line: (position: (100, 200)), plane: (hidden: false)),)),
  zaxis: (instances: ((line: (position: (100, 0)), plane: (hidden: false)),)),
  pt3d.plot3d(xp, xp.map(x => calc.log(x) * 100), xp.map(x => (
    calc.log(x) * 100
  ))),
  pt3d.vec3d((100, 0, 0), (100, 100, 100)),
)

// #pt3d.diagram(
//   stroke: blue,
//   xaxis: (lim: (-400,400)),
//   yaxis: (lim: (-400,400)),
//   zaxis: (lim: (-400,400)),
//   title: "something",
//   pt3d.plane3d(pt3d.plane-point-normal((4, -7, 2), (0, 1, 2))),
//   pt3d.plane3d(pt3d.plane-parametric((0, 1, 2), (3, 2, 1), (-1, 0, 2))),
//   pt3d.plane3d(pt3d.plane-coordinate(4, -7, 2, 3)),
//   pt3d.plane3d(pt3d.plane-normal((4, -7, 2), -3)),
//   pt3d.plane3d(pt3d.plane-hesse(
//     pt3d.normalize-vec((4, -7, 2)),
//     -3 / pt3d.length-vec((4, -7, 2)),
//   )),
//   pt3d.plane3d(pt3d.plane-points(p1, p2, p3)),
//   pt3d.vec3d((4, -7, 2)),
// )
// #pt3d.diagram(
//   title: "asdf",
//   stroke: blue,
//   pt3d.plane3d(pt3d.plane-normal((1, 2, 4), 1), label: "plane"),
//   pt3d.line3d(pt3d.line-parametric((1, 2, 3), (2, 0, 1)), label: "line"),
//   pt3d.line3d(pt3d.line-parametric((1, 2, 3), (2, 0, 0))),
//   pt3d.line3d(pt3d.line-parametric((1, 2, 3), (2, 0, 2))),
// )
//
// #pt3d.diagram(
//   title: "test",
//   stroke: blue,
//   width: 12cm,
//   height: 12cm,
//   xaxis: (lim: (-2, 5)),
//   yaxis: (lim: (-5, 5)),
//   zaxis: (lim: (-5, 5)),
//   pt3d.planeparam3d(
//     (x, y) => y * calc.sin(x) - x * calc.cos(y),
//     stroke-color-fn: (x, y, z) => pt3d.rgb-clamp(0, 0, -z * 50 + 120),
//     fill-color-fn: (x, y, z) => pt3d.rgb-clamp(150, 50, -z * 50 + 150),
//     steps: 50,
//   ),
// )
// #pt3d.diagram(
//   title: "test",
//   width: 12cm,
//   height: 12cm,
//   xaxis: (lim: (-2, 5)),
//   yaxis: (lim: (-2, 5)),
//   zaxis: (lim: (-5, 50)),
//   pt3d.planeparam3d(
//     (x, y) => calc.pow(x, 2) + calc.pow(y, 2),
//     stroke: blue.transparentize(60%),
//     fill: blue.transparentize(60%),
//     steps: 50,
//   ),
// )
// #pt3d.diagram(
//   width: 10cm,
//   height: 10cm,
//   xaxis: (
//     lim: (-10, 10),
//     instances: (
//       (plane: (hidden: false, position: -10)),
//     ),
//   ),
//   yaxis: (
//     lim: (-10, 10),
//     instances: (
//       (plane: (hidden: false, position: -10)),
//     ),
//   ),
//   zaxis: (
//     lim: (-10, 10),
//     instances: (
//       (plane: (hidden: false, position: 10)),
//     ),
//   ),
//   // pt3d.plane3d((3, -2, 3), 10, fill: blue.transparentize(50%)),
// )
// #pt3d.diagram(
//   title: [STUFF #sym.Omega],
//   // fill: blue,
//   xaxis: (
//     lim: (-3, 3),
//     // FIXME:
//     // instances: ((plane: (hidden: true), line: (hidden: true)),),
//   ),
//   yaxis: (lim: (-3, 3), instances: ((plane: (hidden: true)),)),
//   zaxis: (lim: (-3, 3), instances: ((plane: (hidden: true)),)),
//   width: 9cm,
//   height: 9cm,
//   rotations: (
//     pt3d.mat-rotate-x(calc.pi / 6),
//     pt3d.mat-rotate-y(calc.pi / 6),
//     pt3d.mat-rotate-z(0),
//   ),
//
//   pt3d.polygon3d(
//     fill: red.transparentize(70%),
//     (3, 0, 3),
//     (3, 0, -3),
//     (-3, 0, -3),
//     (-3, 0, 3),
//   ),
//   pt3d.polygon3d(
//     fill: green.transparentize(70%),
//     (3, 3, 0),
//     (3, -3, 0),
//     (-3, -3, 0),
//     (-3, 3, 0),
//   ),
//   pt3d.polygon3d(
//     fill: blue.transparentize(70%),
//     (0, 3, 3),
//     (0, 3, -3),
//     (0, -3, -3),
//     (0, -3, 3),
//   ),
//   pt3d.path3d(
//     stroke: red,
//     (-1, -1, 1),
//     (1, -1, 1),
//     (1, 1, 1),
//     (-1, 1, 1),
//     (1, 1, 1),
//     (1, 1, -1),
//     (1, -1, -1),
//     (1, -1, 1),
//     (1, -1, -1),
//     (1, -1, -1),
//     (1, 1, -1),
//     (-1, 1, -1),
//     (-1, 1, 1),
//     (-1, -1, 1),
//     (-1, -1, -1),
//     (1, -1, -1),
//     (-1, -1, -1),
//     (-1, 1, -1),
//   ),
//   pt3d.vec3d(
//     label: "1",
//     (3, 3, 3),
//     stroke: gradient.linear(yellow, black),
//   ),
//   pt3d.vec3d(
//     label: "2",
//     (2, 2, 1),
//     stroke: gradient.linear(yellow, black),
//   ),
//   pt3d.vec3d(
//     label: "3",
//     (1, 1, 0),
//     stroke: gradient.linear(yellow, black),
//   ),
// )
