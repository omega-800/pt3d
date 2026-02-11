#import "../lib/pt3d.typ" as pt

#let data = pt.load-csv(read("./csv.csv"))
#let ((xl, yl, zl), data) = pt.load-csv(read("./csv.csv"), with-labels: true)

#grid(
  columns: (auto, auto),
  // pt.diagram(
  //   stroke: blue,
  //   title: "csv data as path",
  //   pt.path(..data),
  // ),
  pt.diagram(
    xaxis: (
      label: xl,
      lim: (0, 10),
    ),
    yaxis: (
      label: yl,
      lim: (0, 10),
    ),
    zaxis: (
      label: zl,
      lim: (0, 10),
      instances: (pt.axisline(position: (0, 10)), pt.axisplane()),
    ),
    stroke: yellow,
    title: "csv data with labels",
    pt.path(..data),
  ),
  //
  // pt.diagram(
  //   stroke: green,
  //   title: "csv data as polygon",
  //   pt.polygon(..data),
  // ),
  // pt.diagram(
  //   stroke: purple,
  //   title: "csv data as vertices",
  //   pt.vertices(..data.windows(3)),
  // ),
)
