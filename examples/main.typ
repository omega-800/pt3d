#import "../lib/pt3d.typ" as pt3d

// #pt3d.diagram(
//   title: "test",
//   // fill: blue,
//   stroke: blue,
//   xaxis: (lim: (-3, 3)),
//   yaxis: (lim: (-3, 3)),
//   zaxis: (lim: (-3, 3)),
//   width: 6cm,
//   height: 6cm,
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
//   pt3d.line3d(
//     label: "1",
//     (3, 3, 3),
//     stroke: gradient.linear(yellow, black),
//   ),
//   pt3d.line3d(
//     label: "2",
//     (2, 2, 1),
//     stroke: gradient.linear(yellow, black),
//   ),
//   pt3d.line3d(
//     label: "3",
//     (1, 1, 0),
//     stroke: gradient.linear(yellow, black),
//   ),
// )
#h(10em)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  stroke: blue,
  width: 16cm,
  height: 16cm,
  xaxis: (
    lim: (-10, 10),
    instances: (
      (
        plane: (hidden: false, position: 10),
        line: (hidden: false, position: (-10, 10)),
      ),
    ),
  ),
  yaxis: (
    lim: (-10, 10),
    instances: (
      (
        plane: (hidden: false, position: 10),
        line: (hidden: false, position: (-10, 10)),
      ),
    ),
  ),
  zaxis: (
    lim: (-10, 10),
    instances: (
      (
        plane: (hidden: false, position: 10),
        line: (hidden: false, position: (-10, 10)),
      ),
    ),
  ),
  pt3d.planeparam3d(
    (x, y) => (calc.sin(x) + calc.cos(y)) * 2,
    stroke: blue,
    fill: blue.transparentize(90%),
    color-fn: (x, y, z) => pt3d
      .rgb-clamp((0, 0, -z * 100)),
    steps: 50,
  ),
  pt3d.lineparam3d(
    (x, y, z) => (x * 2, calc.cos(y), calc.sin(z)),
    stroke: red,
    steps: 100,
    label: "fun",
  ),
)

// \
// \
// \
// \
// \
// #pt3d.diagram(
//   title: "test",
//   // fill: blue,
//   stroke: blue,
//   width: 4cm,
//   height: 4cm,
//   xaxis: (
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: 0), format-ticks: none),
//     ),
//   ),
//   yaxis: (
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: 0), format-ticks: none),
//     ),
//   ),
//   zaxis: (
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: 0), format-ticks: none),
//     ),
//   ),
// )
// #h(2em)
// #pt3d.diagram(
//   title: "test",
//   // fill: blue,
//   stroke: blue,
//   width: 3cm,
//   height: 3cm,
//   xaxis: (
//     instances: ((format-ticks: none),),
//     lim: (-1, 1),
//   ),
//   yaxis: (
//     instances: ((format-ticks: none),),
//     lim: (-1, 1),
//   ),
//   zaxis: (
//     lim: (-5, 5),
//   ),
// )
// #h(5em)
// #pt3d.diagram(
//   title: "test",
//   // fill: blue,
//   stroke: blue,
//   width: 4cm,
//   height: 4cm,
//   xaxis: (
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: -1), format-ticks: none),
//       (plane: (hidden: false, position: 1), format-ticks: none),
//     ),
//   ),
//   yaxis: (
//     format-ticks: none,
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: -1), format-ticks: none),
//       (plane: (hidden: false, position: 1), format-ticks: none),
//     ),
//   ),
//   zaxis: (
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: -1), format-ticks: none),
//       (plane: (hidden: false, position: 1), format-ticks: none),
//     ),
//   ),
// )
//
// \
// \
//
// lmao shit's fucked
//
// #pt3d.diagram(
//   title: "test Z",
//   // fill: blue,
//   stroke: blue,
//   width: 4cm,
//   height: 4cm,
//   xaxis: (lim: (-5, 3)),
//   yaxis: (lim: (-3, 1)),
//   zaxis: (
//     lim: (-2, 2),
//     instances: (
//       (plane: (hidden: false, position: 0)),
//     ),
//   ),
// )
// #h(2em)
// #pt3d.diagram(
//   title: "test X",
//   // fill: blue,
//   stroke: blue,
//   width: 4cm,
//   height: 4cm,
//   xaxis: (
//     lim: (-2, 2),
//     instances: (
//       (plane: (hidden: false, position: 1)),
//     ),
//   ),
//   yaxis: (lim: (-3, 3)),
//   zaxis: (lim: (-1, 1)),
// )
// #h(5em)
// #pt3d.diagram(
//   title: "test Y",
//   // fill: blue,
//   stroke: blue,
//   width: 4cm,
//   height: 4cm,
//   xaxis: (lim: (-2, 2)),
//   yaxis: (
//     lim: (-1, 1),
//     instances: (
//       (plane: (hidden: false, position: 1)),
//     ),
//   ),
//   zaxis: (lim: (-2, 2)),
// )
// #v(1em)
// #pt3d.diagram(
//   title: "test X",
//   // fill: blue,
//   stroke: blue,
//   width: 4cm,
//   height: 4cm,
//   xaxis: (
//     lim: (-2, 2),
//     instances: (
//       (plane: (position: 1, hidden: false), ticks: (-1, -0.5, 0, 0.5, 1)),
//     ),
//   ),
//   // xaxis: (
//   //   ticks: (-1, -0.5, 0, 0.5, 1),
//   //   instances: (
//   //     (plane: (hidden: false), position: -1),
//   //     (plane: (hidden: false), position: 1),
//   //   ),
//   // ),
//   // yaxis: (
//   //   ticks: (-1, -0.25, -0.5, -0.75, 0, 0.25, 0.5, 0.75, 1),
//   //   instances: (
//   //     (plane: (hidden: false), position: -1),
//   //     (plane: (hidden: false), position: 1),
//   //   ),
//   // ),
//   // zaxis: (
//   //   instances: (
//   //     (plane: (hidden: false), position: -1),
//   //     (plane: (hidden: false), position: 1),
//   //   ),
//   // ),
//   // pt3d.plane3d((0, 0, 1), 0, stroke: black, fill: black.transparentize(80%)),
//   // pt3d.plane3d((0, 1, 0), 0, stroke: black, fill: black.transparentize(80%)),
//   // pt3d.plane3d((2, 2, 2), 3, stroke: black, fill: black.transparentize(80%)),
// )
//
// // #rect(width: 100%, height: 5pt, fill: pt3d.pat)
