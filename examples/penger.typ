#import "../lib/pt3d.typ" as pt

#set page(margin: 0pt)
#pt.diagram(
  width: 21cm,
  height: 28.9cm,
  title: [*penger*],
  pt.vertices(
    stroke: black,
    fill: black.transparentize(90%),
    ..pt.load-obj(read("../examples/penger.obj")),
  ),
)
#align(center, link("https://github.com/Max-Kawula/penger-obj"))
