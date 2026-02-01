#import "elem.typ": *
#import "linalg.typ": *
#import "canvas.typ": *
#import "eval.typ": *

// FIXME:
// https://en.wikipedia.org/wiki/Graph_drawing
// https://computergraphics.stackexchange.com/questions/1761/strategy-for-connecting-2-points-without-intersecting-previously-drawn-segments

#let n-points-on = (from, to, n) => range(0, n + 1).map(i => (
  from + i * ((to - from) / n)
))
// why did i do this exactly?
#let n-points-on-cube = (
  ((xfrom, xto), (yfrom, yto), (zfrom, zto)),
  n,
) => n-points-on(xfrom, xto, n).zip(
  n-points-on(yfrom, yto, n),
  n-points-on(zfrom, zto, n),
)
#let x-y-points = (((xfrom, xto), (yfrom, yto), ..x), n) => n-points-on(
  xfrom,
  xto,
  n,
).map(x => n-points-on(yfrom, yto, n).map(y => (x, y)))

#let render-planeparam((on-canvas, _, dim, ..x), elem) = {
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let p-x-y = x-y-points(dim, steps)
  let p-x-y-z = p-x-y.map(pa => pa.map(((x, y)) => (
    x,
    y,
    (elem.planeparam)(x, y),
  )))
  let p-y-x-z = ()
  // FIXME: nothing in this codebase is performant but this is just laziness
  for i in range(0, p-x-y-z.at(0).len()) {
    let row = ()
    for pa in p-x-y-z {
      row.push(pa.at(i))
    }
    p-y-x-z.push(row)
  }


  let color-fn = (p, fn, def) => if fn != none { fn(..p) } else { def }

  // panic(p-x-y-z, p-y-x-z)
  let p-x-y = p-x-y-z.map(p => p
    .map(on-canvas)
    .filter(p => not p.any(out-of-bounds)))
  // let p-y-x = p-y-x-z.map(p => p
  //   .map(on-canvas)
  //   .filter(p => not p.any(out-of-bounds)))
  // TODO: check bounds
  let r = p-x-y-z.rev()
  for (i, f) in r.slice(0, r.len() - 1).enumerate() {
    for (ii, ff) in f.slice(0, f.len() - 1).enumerate() {
      let p1 = ff
      let p2 = r.at(i + 1).at(ii + 1)
      place(polygon(
        stroke: color-fn(p1, elem.color-fn, elem.stroke),
        fill: color-fn(p1, elem.color-fn, elem.fill),
        on-canvas(ff),
        on-canvas(f.at(ii + 1)),
        on-canvas(r.at(i + 1).at(ii)),
      ))
      place(polygon(
        stroke: color-fn(p2, elem.color-fn, elem.stroke),
        fill: color-fn(p2, elem.color-fn, elem.fill),
        on-canvas(f.at(ii + 1)),
        on-canvas(r.at(i + 1).at(ii)),
        on-canvas(r.at(i + 1).at(ii + 1)),
      ))
    }

    //     for (ii, ff) in f.slice(0, f.len() - 1).enumerate() {
    //       for (j, s) in p-y-x.slice(0, p-y-x.len() - 1).enumerate() {
    //         for (jj, ss) in s.slice(0, s.len() - 1).enumerate() {
    // //   panic(
    // // f,s,
    // //             ff,
    // //             p-x-y.at(i+1).at(ii),
    // //             p-y-x.at(j+1).at(jj),
    // //             ss,
    // //   )
    //           place(polygon(
    //             stroke: elem.stroke,
    //             fill: elem.fill,
    //             ff,
    //             ss,
    //             f.at(ii+1),
    //             s.at(jj+1),
    //           ))
    //         }
    //       }
    //     }
  }
  // for l in p-x-y-z {
  //   place(path(
  //     stroke: elem.stroke,
  //     ..l.map(on-canvas).filter(p => not p.any(out-of-bounds)),
  //   ))
  // }
  // for l in p-y-x-z {
  //   place(path(
  //     stroke: elem.stroke,
  //     ..l.map(on-canvas).filter(p => not p.any(out-of-bounds)),
  //   ))
  // }
}

#let render-lineparam((on-canvas, _, dim, ..x), elem) = {
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let points = n-points-on-cube(dim, steps).map(p => (elem.lineparam)(..p))
  if elem.label != none {
    let (dx, dy) = on-canvas(points.last())
    place(dx: dx, dy: dy, elem.label)
  }
  place(path(
    stroke: elem.stroke,
    ..points.map(on-canvas).filter(p => not p.any(out-of-bounds)),
  ))
}

#let render-path((on-canvas, ..x), elem) = {
  place(path(stroke: elem.stroke, ..elem.path.map(on-canvas)))
}

#let render-polygon((on-canvas, ..x), elem) = {
  place(polygon(
    fill: elem.fill,
    stroke: elem.stroke,
    ..elem.polygon.map(on-canvas),
  ))
}

#let render-plane(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let elem-eval = eval-plane(ctx, elem)
  place(polygon(
    fill: elem-eval.fill,
    stroke: elem-eval.stroke,
    ..connect-circle-2d(..elem-eval.plane.map(on-canvas)),
  ))
}

#let render-line((on-canvas, ..x), elem) = {
  if elem.label != none {
    let (dx, dy) = on-canvas(elem.line.at(1))
    place(dx: dx, dy: dy, elem.label)
  }

  place(line(
    stroke: elem.stroke,
    start: on-canvas(elem.line.at(0)),
    end: on-canvas(elem.line.at(1)),
  ))
}

#let render-axis(ctx, elem) = {
  let (on-canvas, _, dim, (xas, yas, zas)) = ctx
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim

  let axis-ticks = (kind: "x", ticks: auto, nticks: auto, ..x) => {
    let (tto, tfrom) = if kind == "x" {
      (xto, xfrom)
    } else if kind == "y" {
      (yto, yfrom)
    } else {
      (zto, zfrom)
    }
    let span = tto - tfrom
    if (
      ticks == auto and nticks == auto
    ) {
      n-points-on(tfrom, tto, 10)
    } else if ticks == auto {
      n-points-on(tfrom, tto, nticks)
    } else {
      ticks
    }
  }

  let filter-tick-axes = a => (
    a
      .instances
      .filter(
        i => (
          (not i.plane.hidden or not i.line.hidden)
            and not i.hidden
            and i.format-ticks != none
            and (i.ticks != none or i.nticks != none)
        ),
      )
      .at(0, default: none)
  )

  let first-tick-axis = a => {
    let ax = filter-tick-axes(a)
    if ax == none { none } else { axis-ticks(..ax) }
  }

  let xticks = first-tick-axis(xas)
  let yticks = first-tick-axis(yas)
  let zticks = first-tick-axis(zas)

  let (point, point-p, point-r, point-n, cur, from, to) = if elem.kind == "x" {
    (
      x => (x, 0, 0),
      ((x, y, z), n) => (x, y + n, z + n),
      ((x, y, z), n) => (n, y, z),
      ((y, z), n) => (n, y, z),
      ((x, y, z)) => x,
      xfrom,
      xto,
    )
  } else if elem.kind == "y" {
    (
      y => (0, y, 0),
      ((x, y, z), n) => (x + n, y, z + n),
      ((x, y, z), n) => (x, n, z),
      ((x, z), n) => (x, n, z),
      ((x, y, z)) => y,
      yfrom,
      yto,
    )
  } else {
    (
      z => (0, 0, z),
      ((x, y, z), n) => (x + n, y + n, z),
      ((x, y, z), n) => (x, y, n),
      ((x, y), n) => (x, y, n),
      ((x, y, z)) => z,
      zfrom,
      zto,
    )
  }
  let pfrom = point(from)
  let pto = point(to)
  let place-line = (start, end) => place(line(
    stroke: elem.stroke,
    start: on-canvas(start),
    end: on-canvas(end),
  ))
  let mid = (f, s) => f.enumerate().map(((i, n)) => (s.at(i) + n) / 2)
  let line-from = point-n(elem.line.position, from)
  let line-to = point-n(elem.line.position, to)
  if not elem.plane.hidden {
    let plane-points = if elem.kind == "x" {
      (
        (elem.plane.position, yfrom, zfrom),
        (elem.plane.position, yto, zfrom),
        (elem.plane.position, yto, zto),
        (elem.plane.position, yfrom, zto),
      )
    } else if elem.kind == "y" {
      (
        (xfrom, elem.plane.position, zfrom),
        (xto, elem.plane.position, zfrom),
        (xto, elem.plane.position, zto),
        (xfrom, elem.plane.position, zto),
      )
    } else {
      (
        (xfrom, yfrom, elem.plane.position),
        (xto, yfrom, elem.plane.position),
        (xto, yto, elem.plane.position),
        (xfrom, yto, elem.plane.position),
      )
    }
    render-polygon(
      ctx,
      polygon3d(..plane-points, stroke: elem.stroke, fill: elem.fill),
    )
    // render-plane(ctx, plane3d(
    //   pto,
    //   elem.position,
    //   stroke: elem.stroke,
    //   fill: elem.fill,
    // ))
  }
  if not elem.line.hidden {
    let (dx, dy) = on-canvas(mid(line-from, line-to))
    if elem.label != none {
      // FIXME:
      place(
        dx: if elem.kind == "z" { dx - 13% } else if elem.kind == "y" {
          dx - 12% // proffeshunal
        } else { dx - 2% },
        dy: if elem.kind == "y" { dy } else if elem.kind == "z" {
          dy - 4%
        } else { dy },
        pad(16pt, elem.label),
      )
    }
    // TODO: tip, toe
    place-line(line-from, line-to)
  }
  if elem.format-ticks != none {
    let ticks = ()
    if type(elem.ticks) == array {
      ticks = elem.ticks.filter(t => t <= to and t >= from)
    } else {
      let nticks = if elem.nticks == auto {
        (to - from) / 10
      } else { elem.nticks }
      ticks = range(0, int((to - from) / nticks) + 1).map(i => (
        from + i * nticks
      ))
    }

    // if elem.format-subticks != none {}

    if not elem.line.hidden {
      // FIXME: depends on position of axis
      for tick in ticks {
        let (px, py, pz) = point-r(line-from, tick)

        let (start, end) = (
          if elem.line.position.at(0) - elem.line.position.at(1) > 0 {
            if elem.kind == "x" {
              ((px, py, pz - 0.1), (px, py, pz + 0.1))
            } else if elem.kind == "y" {
              ((px - 0.1, py, pz), (px + 0.1, py, pz))
            } else {
              ((px - 0.1, py, pz), (px + 0.1, py, pz))
            }
          } else {
            if elem.kind == "x" {
              ((px, py - 0.1, pz), (px, py + 0.1, pz))
            } else if elem.kind == "y" {
              ((px, py, pz - 0.1), (px, py, pz + 0.1))
            } else {
              ((px, py - 0.1, pz), (px, py + 0.1, pz))
            }
          }
        ).map(on-canvas)

        place(line(
          stroke: elem.stroke,
          start: start,
          end: end,
        ))
        // FIXME:
        let (dx, dy) = if elem.kind == "z" { end } else { start }
        place(
          dx: if elem.kind == "x" { dx } else { dx - 4% },
          dy: if elem.kind == "z" { dy } else { dy + 2% },
          text(size: 0.75em)[#calc.round(tick, digits: 2)],
        )
      }
    }
    if not elem.plane.hidden {
      if elem.kind == "z" {
        for tick in xticks {
          place-line(
            (tick, yfrom, elem.plane.position),
            (tick, yto, elem.plane.position),
          )
        }
        for tick in yticks {
          place-line(
            (xfrom, tick, elem.plane.position),
            (xto, tick, elem.plane.position),
          )
        }
      } else if elem.kind == "y" {
        for tick in xticks {
          place-line(
            (tick, elem.plane.position, zfrom),
            (tick, elem.plane.position, zto),
          )
        }
        for tick in zticks {
          place-line(
            (xfrom, elem.plane.position, tick),
            (xto, elem.plane.position, tick),
          )
        }
      } else {
        for tick in yticks {
          place-line(
            (elem.plane.position, tick, zfrom),
            (elem.plane.position, tick, zto),
          )
        }
        for tick in zticks {
          place-line(
            (elem.plane.position, yfrom, tick),
            (elem.plane.position, yto, tick),
          )
        }
      }
    }
  }
}

#let render = (
  ctx,
  elem,
) => {
  if "axis" in elem {
    render-axis(ctx, elem)
  } else if "path" in elem {
    render-path(ctx, elem)
  } else if "polygon" in elem {
    render-polygon(ctx, elem)
  } else if "plane" in elem {
    render-plane(ctx, elem)
  } else if "planeparam" in elem {
    render-planeparam(ctx, elem)
  } else if "line" in elem {
    render-line(ctx, elem)
  } else if "lineparam" in elem {
    render-lineparam(ctx, elem)
  }
}
