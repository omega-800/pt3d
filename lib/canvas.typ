#import "util.typ": *
#import "eval.typ": *
#import "elem.typ": *

#let overflow-correction = ns => {
  let s = ns.filter(out-of-bounds-2d).sorted()
  let high = calc.max(s.last(default: 100%), 100%)
  let low = calc.min(s.first(default: 0%), 0%)
  let span = high - low
  (
    -low / span * 100%,
    (100% / span) * 100%,
  )
}

#let rescale = ((xo, xscale), (yo, yscale)) => (
  (x, y),
) => {
  // panic(yo,yscale,y, y * yscale + yo)
  (x * xscale + xo, y * yscale + yo)
}

#let order-axes = ((xo, yo, zo)) => ((x, y, z)) => (
  // FIXME: flip z properly
  ((x, xo), (y, yo), (-z, zo)).sorted(key: it => it.at(1)).map(it => it.at(0))
)

#let canvas(dim, transform-fn, rotate-fn, scale-fn) = p => scale-fn(
  ortho-proj(
    dim,
    rotate-fn(transform-fn(p)),
  ),
)

// FIXME: wonky
#let def-lim = (min, max, lim: (-1, 1), ..x) => {
  let def = (i, def) => if type(i) == float or type(i) == int { i } else { def }
  let lim = (def(def(lim.at(0), min), 1), def(def(lim.at(1), max), -1))
  if lim.at(0) == lim.at(1) {
    lim.at(0) -= 1
    lim.at(1) += 1
  }
  lim
}

// TODO: make the stuff that's badly implemented better

#let gen-ctx(
  title,
  (width, height),
  (xaxis, yaxis, zaxis),
  rotations,
  children,
  noclip,
) = {
  // FIXME: wonky
  let xas = axis(kind: "x", ..xaxis)
  let yas = axis(kind: "y", ..yaxis)
  let zas = axis(kind: "z", ..zaxis)

  let ((xmin, ymin, zmin), (xmax, ymax, zmax)) = eval-min-bounds(
    (xas, yas, zas),
    ..children,
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
  // panic(
  //   plot-extremes.map(((x, y)) => x).filter(out-of-bounds-2d).sorted().first(),
  //   plot-extremes.map(((x, y)) => x).filter(out-of-bounds-2d).sorted().last(),
  //   overflow-correction(plot-extremes.map(((x, y)) => x)),
  //   plot-extremes.map(((x, y)) => y).filter(out-of-bounds-2d).sorted().first(),
  //   plot-extremes.map(((x, y)) => y).filter(out-of-bounds-2d).sorted().last(),
  //   overflow-correction(plot-extremes.map(((x, y)) => y)),
  // )
  // panic(plot-extremes)
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

  let offset = 0pt
  if title != none {
    // huh why does measuring block provide scuffed dimensions
    offset = measure(title).height + 10pt
  }

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
    intersection-canvas: (from, to) => intersection-3d-cube((from, to), dim),
    out-of-bounds: out-of-bounds-3d(..dim),
    clamp-to-bounds: clamp-to-bounds-3d(..dim),
    rotate-canvas: rotate-canvas,
    noclip: noclip,
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
              mid-vec(point-n(a.line.position, max), point-n(
                a.line.position,
                min,
              )),
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
  ((xpad, xadj, ypad, yadj, offset), ctx)
}
