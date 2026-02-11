#import "../lib/pt3d.typ" as pt

#let data = pt.load-csv(read("./csv.csv"))
#let ((xl, yl, zl), data) = pt.load-csv(read("./csv.csv"), with-labels: true)

#grid(
  columns: (auto, auto),
  pt.diagram(
    stroke: blue,
    title: "csv data as path",
    pt.path(..data),
  ),
  pt.diagram(
    xaxis: (
      label: xl,
      instances: (
        pt.axisline(format-ticks: (label-format: none)),
        pt.axisplane(),
      ),
    ),
    yaxis: (label: yl),
    zaxis: (label: zl),
    stroke: yellow,
    title: "csv data with labels",
    pt.path(..data),
  ),

  pt.diagram(
    stroke: green,
    title: "csv data as polygon",
    pt.polygon(..data),
  ),
  pt.diagram(
    stroke: purple,
    title: "csv data as vertices",
    pt.vertices(..data.windows(3)),
  ),
)
