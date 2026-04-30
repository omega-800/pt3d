#import "/lib/pt3d.typ" as pt
#import "@preview/suiji:0.5.1"
#import "@preview/lilaq:0.5.0" as lq

#set page(height: 9cm, width: 18cm, margin: 0pt)

// = Elements

// == Distribution

#let exbox = c => {
  grid(
    columns: (1fr, auto),
    rows: (1fr,),
    align: center + horizon,
    box(align(left, (raw(lang: "typst", c)))),
    eval(
      mode: "markup",
      "
      #import \"/lib/pt3d.typ\" as pt
      #import \"@preview/suiji:0.5.1\"
      #import \"@preview/lilaq:0.5.0\" as lq

      #let num = 50
      #let xs = pt.linspace(-10, 10, num: num)

      #let cfn = (x, y, z) => pt.rgb-clamp(
        z * 40,
        255 - calc.abs(z) * 10,
        -z * 40,
      )
      #let cfn0c = (x, y, z) => (
        z * 40,
        255 - calc.abs(z - 5) * 10,
        if z == 0 { 255 } else { 10 / z },
      )
      #let cfn0 = (x, y, z) => pt.rgb-clamp(
        ..cfn0c(x, y, z),
      )
      #let cfn0s = (x, y, z) => pt.rgb-clamp(
        ..cfn0c(x, y, z).map(i => i - 50),
      )
      #let rng = suiji.gen-rng-f(26)
      #let (rng, dxs) = suiji.normal-f(rng, size: 100, scale: 2.5)
      #let (rng, dys) = suiji.normal-f(rng, size: 100, scale: 2.5)

      #let diagram = pt.diagram.with(
        xaxis: (lim: (-10, 10), nticks: 5),
        yaxis: (lim: (-10, 10), nticks: 5),
        zaxis: (lim: (-10, 10), nticks: 5),
      )
      "
        + c,
    ),
  )
}

#exbox(
  "#lq.diagram(
  xlim: (-10, 10),
  ylim: (-10, 10),
  lq.scatter(dxs, dys),
)",
)
#exbox(
  "#diagram(
  zaxis: (lim: (0, 10)),
  pt.distribution(
    fill-color-fn: cfn0,
    stroke-color-fn: cfn0s,
    mark: none,
    dxs,
    dys,
  ),
)",
)

// == Line plots

#exbox(
  "#diagram(
  pt.lineplot(
    xs.map(x => calc.cos(x) * 5),
    xs,
    xs.map(x => calc.sin(x) * 10),
    stroke-color-fn: cfn,
  ),
)
",
)
// == Plane plots
#exbox(
  "
#let num = 30
#let domain = pt.domain((0, calc.pi), 
    (0, 1.75 * calc.pi), v-num: num)
#diagram(
  pt.planeplot(
    domain.map(((u, v)) => u * calc.sin(v) * 5),
    domain.map(((u, v)) => u * calc.cos(v) * 5),
    domain.map(((u, v)) => u * 10 - 10),
    num: num,
    stroke-color-fn: cfn,
    fill-color-fn: cfn,
  ),
)",
)

// == Paths

#exbox(
  "#diagram(
  pt.path(
    ..(
      (-1, -1, 1), (1, -1, 1), (1, 1, 1),
      (-1, 1, 1), (1, 1, 1), (1, 1, -1),
      (1, -1, -1), (1, -1, 1), (1, -1, -1),
      (1, -1, -1), (1, 1, -1), (-1, 1, -1),
      (-1, 1, 1), (-1, -1, 1), (-1, -1, -1),
      (1, -1, -1), (-1, -1, -1), (-1, 1, -1),
    ).map(((x, y, z)) => (
      x * 7 - 3, y * 4 - 4, z * 8 + 2)
    ),
  ),
)",
)

// == Vertices

// #diagram()

// == Polygons

// #diagram()

// == Vectors

#exbox(
  "#diagram(
  pt.vec((9, 5, 0)),
  pt.vec((0, 4, 8)),
  pt.vec((-10, 10, 0), (0, 5, 9)),
  pt.vec((10, -10, 0), (0, 4, 9)),
)",
)

// == Vector fields

// TODO: util fn
// #let qns = pt.linspace(-10, 10, num: 5)
// #let qxs = ()
// #let qys = ()
// #let qzs = ()
// #for (x, y, z) in pt.meshgrid(qns, qns, qns) {
//   qxs.push(x)
//   qys.push(y)
//   qzs.push(z)
// }
//
// #diagram(
//   pt.quiver(qxs, qys, qzs, (x, y, z) => {
//     (x / z, y / z, z / 2)
//   }),
// )

// == Parametrized planes

#exbox(
  "#diagram(
  pt.planeparam(
    (x, y) => {
      let z = (1 - x * x - y * y) / 10
      (if z < 0 { z } else { calc.sqrt(z) }
          + 9)
    },
    stroke-color-fn: cfn,
    fill-color-fn: cfn,
    steps: 20,
  ),
)",
)

// == Planes

#exbox(
  "#diagram(
  pt.plane(
    pt.plane-normal((1, 0.5, 0), 2),
  ),
)",
)

// == Lines

#exbox("#diagram(
  pt.line(pt.line-parametric((1, 2, 3), (2, 0, 1))),
)")

// == Ticks
//
// #diagram()
//
// == Axes
//
// #diagram()
//
// == Legend
//
// #diagram()
//
// == Marks
//
// = Data
//
// == CSV
//
// == OBJ
