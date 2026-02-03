#import "render.typ": *
#import "elem.typ": *
#import "style.typ": *
#import "linalg.typ": *
#import "canvas.typ": *

// https://www.mauriciopoppe.com/notes/computer-graphics/viewing/projection-transform/
// http://www.songho.ca/opengl/gl_projectionmatrix.html

// FIXME: wonky
#let def-lim = (min, max, lim: (-1, 1), ..x) => {
  let def = (i, def) => if type(i) == int { i } else { def }
  (def(def(lim.at(0), min), 1), def(def(lim.at(1), max), -1))
}

#let diagram(
  width: 6cm,
  height: 4cm,
  title: none,
  legend: (:),
  grid: auto,
  xaxis: (:),
  yaxis: (:),
  zaxis: (:),
  margin: 6%,
  cycle: petroff10,
  fill: none,
  stroke: none,
  rotations: (
    (
      (calc.sqrt(3), 0, -calc.sqrt(3)),
      (-1, 2, -1),
      (
        calc.sqrt(2),
        calc.sqrt(2),
        calc.sqrt(2),
      ),
    ).map(r => r.map(i => i / calc.sqrt(6))),
  ),
  ..children,
) = context {
  // FIXME: wonky
  let xas = axis(kind: "x", ..xaxis)
  let yas = axis(kind: "y", ..yaxis)
  let zas = axis(kind: "z", ..zaxis)

  let ((xmin, ymin, zmin), (xmax, ymax, zmax)) = eval-min-bounds(
    (xas, yas, zas),
    ..children.pos(),
  )

  // FIXME: wonky
  let (ox, oz, oy) = (xas, zas, yas)
    .enumerate()
    .map(((i, a)) => if a.order != auto { a.order } else { i })
  let a-order = (ox, oy, oz)

  let xlim = def-lim(xmin, xmax, ..xas)
  let ylim = def-lim(ymin, ymax, ..yas)
  let zlim = def-lim(zmin, zmax, ..zas)

  let dim = (xlim, ylim, zlim)
  let (xas, yas, zas) = axes-defaults(xas, yas, zas, dim)

  let transform-canvas = order-axes(a-order)
  let rotate-canvas = v => apply-matrices(v, ..rotations)

  // TODO: only include rendered points
  let plot-extremes = cube-vertices(dim).map(canvas(
    dim,
    transform-canvas,
    rotate-canvas,
    x => x.map(i => i * 100%),
  ))

  let on-canvas = canvas(
    dim,
    transform-canvas,
    rotate-canvas,
    // x => x.map(i=>i*10%)

    rescale(
      overflow-correction(plot-extremes.map(((x, y)) => x)),
      overflow-correction(plot-extremes.map(((x, y)) => y)),
    ),
  )

  // TODO: this is wrong and has to be properly implemented for all axis positions and label formats
  /*
   let get-tick-format = a => a
     .instances
     .filter(i => not i.line.hidden)
     .map(i => i.format-ticks)
     .sorted(key: i => i.length)
     .at(0, default: (:))
   let get-tick-size = (
     kind: "x",
     length: 0,
     offset: 0,
     label-format: i => text()[#i],
     ..x,
   ) => {
     let from = length / 2 + offset
     let (width, height) = measure(label-format(-10.99))
     if kind == "x" {
       let (x, y) = on-canvas((xmax, ymin - from, zmin))
       (x + width - 100%, height)
     } else if kind == "y" {
       let (x, y) = on-canvas((xmin + from, ymax, zmin))
       // panic(on-canvas((xmin, ymax, zmin)))
       // panic(x, y)
       (x + width, height)
     } else {
       let (x, y) = on-canvas((xmin - from, ymax, zmin))
       (x + width, height)
     }
   }

   let (xw, xh) = get-tick-size(..get-tick-format(xas), kind: "x")
   let (yw, yh) = get-tick-size(..get-tick-format(yas), kind: "y")
   let (zw, zh) = get-tick-size(..get-tick-format(zas), kind: "z")
   // panic(xw, xh, yw, yh, zw, zh)
   // let tick-width = calc.max(xw, yw, zw)
   // let tick-height = calc.max(xh, yh, zh)
   let tick-width = 0%
   let tick-height = 0%
   // panic(tick-width, tick-height)
  */

  let ctx = (
    on-canvas,
    dim,
    out-of-bounds-3d(..dim),
    clamp-to-bounds-3d(..dim),
    (xas, yas, zas),
    rotate-canvas,
  )
  let content = ()
  let offset = 0pt
  if title != none {
    let title-elem = block(width: 100%, align(center, pad(0.5em, title)))
    content.push(title-elem)
    offset = measure(title-elem).height
  }

  let plot = [
    #for xa in xas.instances {
      render(ctx, xa)
    }
    #for ya in yas.instances {
      render(ctx, ya)
    }
    #for za in zas.instances {
      render(ctx, za)
    }

    #for c in children.pos() {
      render(ctx, c)
    }
  ]

  // FIXME: width/height of axis labels
  content.push(
    place(
      top + right,
      dx: - 2em,
      block(
        fill: fill,
        // we do a little cheating over here
        width: 100% - 6em, /* tick-width */
        height: 100% - offset - 2em, /* tick-height */
        plot,
      ),
    ),
  )
  box(height: height, width: width, stroke: stroke, stack(..content))
}
