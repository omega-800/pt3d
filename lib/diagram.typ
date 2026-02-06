#import "render.typ": *
#import "elem.typ": *
#import "style.typ": *
#import "linalg.typ": *
#import "canvas.typ": *

// https://www.mauriciopoppe.com/notes/computer-graphics/viewing/projection-transform/
// http://www.songho.ca/opengl/gl_projectionmatrix.html

// FIXME: wonky
#let def-lim = (min, max, lim: (-1, 1), ..x) => {
  let def = (i, def) => if type(i) == float or type(i) == int { i } else { def }
  (def(def(lim.at(0), min), 1), def(def(lim.at(1), max), -1))
}

#let diagram(
  width: 8cm,
  height: 6cm,
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
    // FIXME: previous solution was more correct than this one. bug happens when abs(lim-min) < abs(lim-max)
    rescale(
      overflow-correction(plot-extremes.map(((x, y)) => x)),
      overflow-correction(plot-extremes.map(((x, y)) => y)),
    ),
  )

  let content = ()
  let offset = 0pt
  if title != none {
    let title-elem = block(width: 100%, align(center, pad(0.5em, title)))
    content.push(title-elem)
    offset = measure(title-elem).height
  }

  // TODO: include label/title offset etc.
  let canvas-dim = (
    width: width.to-absolute().pt() * 1pt,
    height: (height.to-absolute().pt() - offset.pt()) * 1pt,
  )
  let ctx = (
    canvas-dim: canvas-dim,
    on-canvas: on-canvas,
    map-point-pt: ((x, y)) => (
      (x * canvas-dim.width) / 1pt,
      (y * canvas-dim.height) / 1pt,
    ),
    dim: dim,
    out-of-bounds: out-of-bounds-3d(..dim),
    clamp-to-bounds: clamp-to-bounds-3d(..dim),
    rotate-canvas: rotate-canvas,
  )
  let (xas, yas, zas) = axes-defaults(xas, yas, zas, ctx)
  ctx.axes = (xas, yas, zas)

  // FIXME: bad bad code
  let ((xoff-min, xoff-max), (yoff-min, yoff-max)) = (xas, yas, zas)
    .map(axis => {
      let (point-n, point-r, min, max) = axis-helper-fn(ctx, axis)
      axis
        .instances
        .filter(a => not a.line.hidden)
        .map(a => {
          let res = ()
          if a.label != none {
            res.push(axis-tick-pos(
              ctx,
              axis.kind,
              a.line.position,
              mid(point-n(a.line.position, max), point-n(a.line.position, min)),
              1em.to-absolute().pt() * 3.5pt,
              a.label,
            ))
          }
          if a.format-ticks != none {
            let (length, offset) = a.format-ticks
            let from = ((length / 2) + offset) / 1pt
            let to = ((length / 2) - offset) / 1pt
            for tick in (a.ticks.first(), a.ticks.last()) {
              res.push(axis-tick-pos(
                ctx,
                axis.kind,
                a.line.position,
                point-r(point-n(a.line.position, min), tick),
                1em.to-absolute().pt() * 1pt,
                (a.format-ticks.label-format)(tick),
                from-off: from,
                to-off: to,
              ))
            }
          }
          res
        })
    })
    .flatten()
    .fold(((0pt, canvas-dim.width), (0pt, canvas-dim.height)), (
      ((xmin, xmax), (ymin, ymax)),
      (start, end, label-max),
    ) => {
      let (sx, sy) = start
      let (ex, ey) = end
      let (lx-min, lx-max, ly-min, ly-max) = label-max
      (
        (
          calc.min(xmin, sx, ex, lx-min, lx-max),
          calc.max(xmax, sx, ex, lx-min, lx-max),
        ),
        (
          calc.min(ymin, sy, ey, ly-min, ly-max),
          calc.max(ymax, sy, ey, ly-min, ly-max),
        ),
      )
    })
  let xpad = 0pt - xoff-min
  let xadj = xoff-max - xoff-min - canvas-dim.width
  let ypad = 0pt - yoff-min
  let yadj = yoff-max - yoff-min - canvas-dim.height

  let canvas-dim = (
    width: canvas-dim.width - xadj,
    height: canvas-dim.height - yadj,
  )
  ctx.canvas-dim = canvas-dim
  ctx.map-point-pt = ((x, y)) => (
    (x * canvas-dim.width) / 1pt,
    (y * canvas-dim.height) / 1pt,
  )

  let elems = children
    .pos()
    .enumerate()
    .map(((i, elem)) => {
      let color = cycle.at(calc.rem(i, cycle.len()))
      if "stroke" in elem and elem.stroke == auto {
        elem.stroke = color
      }
      if "fill" in elem and elem.fill == auto {
        elem.fill = color.transparentize(80%)
      }
      elem
    })
  let legend-elems = elems.filter(elem => elem.label != none)

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
    #for c in elems {
      render(ctx, c)
    }
  ]

  if legend-elems.len() > 0 {
    content.push(
      render-legend(ctx, legend-def(..legend), legend-elems),
    )
  }

  // FIXME: width/height of axis labels
  content.push(
    place(
      top + left,
      dx: xpad,
      dy: ypad,
      [
        #block(
          fill: fill,
          // we do a little cheating over here
          width: canvas-dim.width, /* tick-width */
          height: canvas-dim.height, /* tick-height */
          plot,
        )],
    ),
  )
  box(height: height, width: width, stroke: stroke, stack(..content))
}
