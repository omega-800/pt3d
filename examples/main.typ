#import "../lib/pt3d.typ" as pt3d

#pt3d.diagram(
  title: "test",
  // fill: blue,
  xaxis: (lim: (-3, 3)),
  yaxis: (lim: (-3, 3)),
  zaxis: (lim: (-3, 3)),
  width: 6cm,
  height: 6cm,

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
#h(10em)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  xaxis: (
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: -1),
    ),
  ),
  yaxis: (
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: 1),
    ),
  ),
  zaxis: (
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: 1),
    ),
  ),
  width: 6cm,
  height: 6cm,
)
\
\
\
\
\
#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    format-ticks: none,
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: 0),
    ),
  ),
  yaxis: (
    format-ticks: none,
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: 0),
    ),
  ),
  zaxis: (
    format-ticks: none,
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: 0),
    ),
  ),
)
#h(2em)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    format-ticks: none,
    lim: (-1, 1),
  ),
  yaxis: (
    format-ticks: none,
    lim: (-1, 1),
  ),
  zaxis: (
    lim: (-1, 1),
  ),
)
#h(5em)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    format-ticks: none,
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: -1),
      (plane: (hidden: false), position: 1),
    ),
  ),
  yaxis: (
    format-ticks: none,
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: -1),
      (plane: (hidden: false), position: 1),
    ),
  ),
  zaxis: (
    format-ticks: none,
    lim: (-1, 1),
    instances: (
      (plane: (hidden: false), position: -1),
      (plane: (hidden: false), position: 1),
    ),
  ),
)

\
\

lmao shit's fucked

#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    lim: (-2, 5),
    instances: (
      (plane: (hidden: false), position: 1),
    ),
  ),
  yaxis: (lim: (-3, 3)),
  zaxis: (lim: (-5, 1)),
)
#h(2em)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    lim: (-2, 2),
    instances: (
      (plane: (hidden: false), position: 1),
    ),
  ),
  yaxis: (lim: (-3, 3)),
  zaxis: (lim: (-1, 1)),
)
#h(5em)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    lim: (-2, 2),
    instances: (
      (plane: (hidden: false), position: 1),
    ),
  ),
  yaxis: (lim: (-1, 1)),
  zaxis: (lim: (-2, 2)),
)
#pt3d.diagram(
  title: "test",
  // fill: blue,
  width: 4cm,
  height: 4cm,
  xaxis: (
    lim: (-2, 2),
    ticks: (-1, -0.5, 0, 0.5, 1),
    instances: (
      (plane: (hidden: false), position: 1),
    ),
  ),
  // xaxis: (
  //   ticks: (-1, -0.5, 0, 0.5, 1),
  //   instances: (
  //     (plane: (hidden: false), position: -1),
  //     (plane: (hidden: false), position: 1),
  //   ),
  // ),
  // yaxis: (
  //   ticks: (-1, -0.25, -0.5, -0.75, 0, 0.25, 0.5, 0.75, 1),
  //   instances: (
  //     (plane: (hidden: false), position: -1),
  //     (plane: (hidden: false), position: 1),
  //   ),
  // ),
  // zaxis: (
  //   instances: (
  //     (plane: (hidden: false), position: -1),
  //     (plane: (hidden: false), position: 1),
  //   ),
  // ),
  // pt3d.plane3d((0, 0, 1), 0, stroke: black, fill: black.transparentize(80%)),
  // pt3d.plane3d((0, 1, 0), 0, stroke: black, fill: black.transparentize(80%)),
  // pt3d.plane3d((2, 2, 2), 3, stroke: black, fill: black.transparentize(80%)),
)

// #rect(width: 100%, height: 5pt, fill: pt3d.pat)
