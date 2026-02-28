#import "../lib/pt3d.typ" as pt

#grid(
  columns: 2,
  pt.diagram(
    title: "offset +",
    stroke: blue,
    xaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt, offset: 0pt)),),
    ),
    yaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt, offset: 15pt)),),
    ),
    zaxis: (
      // FIXME:
      instances: (pt.axisline(format-ticks: (length: 30pt, offset: 30pt)),),
    ),
  ),
  pt.diagram(
    title: "offset -",
    stroke: blue,
    xaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt, offset: 0pt)),),
    ),
    yaxis: (
      // FIXME:
      instances: (pt.axisline(format-ticks: (length: 30pt, offset: -15pt)),),
    ),
    zaxis: (
      // FIXME:
      instances: (pt.axisline(format-ticks: (length: 30pt, offset: -30pt)),),
    ),
  ),

  pt.diagram(
    title: "long length",
    stroke: blue,
    xaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
    yaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
    zaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
  ),

  pt.diagram(
    // FIXME: label max
    title: "short length",
    stroke: blue,
    xaxis: (
      instances: (pt.axisline(format-ticks: (length: 5pt)),),
    ),
    yaxis: (
      instances: (pt.axisline(format-ticks: (length: 5pt)),),
    ),
    zaxis: (
      instances: (pt.axisline(format-ticks: (length: 5pt)),),
    ),
  ),
  pt.diagram(
    title: "long length",
    stroke: blue,
    xaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
    yaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
    zaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
  ),

  pt.diagram(
    title: "rotated",
    stroke: blue,
    rotations: (pt.mat-rotate-x(.4), pt.mat-rotate-y(-.4), pt.mat-rotate-z(.1)),
    xaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
    yaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
    zaxis: (
      instances: (pt.axisline(format-ticks: (length: 30pt)),),
    ),
  ),

  pt.diagram(
    title: "default lines",
    // FIXME: z label
    stroke: blue,
    xaxis: (instances: (pt.axisline(),)),
    yaxis: (instances: (pt.axisline(),)),
    zaxis: (instances: (pt.axisline(),)),
  ),
  pt.diagram(
    title: "reverse pos",
    stroke: blue,
    xaxis: (instances: (pt.axisline(position: (10, 10)), pt.axisplane())),
    yaxis: (instances: (pt.axisline(position: (10, 10)), pt.axisplane())),
    zaxis: (instances: (pt.axisline(position: (10, -10)), pt.axisplane())),
  ),

  pt.diagram(
    title: "default",
    stroke: blue,
  ),
  pt.diagram(
    title: "no label",
    stroke: blue,
    xaxis: (label: none),
    yaxis: (label: none),
    zaxis: (label: none),
  ),

  pt.diagram(
    title: "no tick labels",
    stroke: blue,
    // FIXME:
    xaxis: (instances: (pt.axisline(format-ticks: none),)),
    yaxis: (instances: (pt.axisline(format-ticks: none),)),
    zaxis: (instances: (pt.axisline(format-ticks: none),)),
  ),
  pt.diagram(
    title: "no labels",
    stroke: blue,
    xaxis: (instances: (pt.axisline(format-ticks: none, label: none),)),
    yaxis: (instances: (pt.axisline(format-ticks: none, label: none),)),
    zaxis: (instances: (pt.axisline(format-ticks: none, label: none),)),
  ),

  pt.diagram(
    title: "center pos",
    stroke: blue,
    xaxis: (instances: (pt.axisline(position: (0, 0)),)),
    yaxis: (instances: (pt.axisline(position: (0, 0)),)),
    zaxis: (instances: (pt.axisline(position: (0, 0)),)),
  ),

  pt.diagram(
    title: "default planes",
    stroke: blue,
    xaxis: (instances: (pt.axisplane(),)),
    yaxis: (instances: (pt.axisplane(),)),
    zaxis: (instances: (pt.axisplane(),)),
  ),
  pt.diagram(
    title: "planes with labels",
    stroke: blue,
    xaxis: (instances: (pt.axisplane(format-ticks: (label-format: x => x)),)),
    yaxis: (instances: (pt.axisplane(format-ticks: (label-format: x => x)),)),
    zaxis: (instances: (pt.axisplane(format-ticks: (label-format: x => x)),)),
  ),

  pt.diagram(
    title: "bug? or feature?",
    stroke: blue,
    xaxis: (
      label: none,
      instances: (pt.axisline(format-ticks: (label-format: none)),),
    ),
    yaxis: (label: none, instances: (pt.axisline(format-ticks: none),)),
    zaxis: (label: none, instances: (pt.axisline(format-ticks: none),)),
  ),
)
