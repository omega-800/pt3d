#import "elem.typ": *
#import "linalg.typ": *
#import "canvas.typ": *

#let n-points-on = (from, to, n) => range(0, n + 1).map(i => (
  from + i * ((to - from) / n)
))
#let n-points-on-cube = (
  ((xfrom, xto), (yfrom, yto), (zfrom, zto)),
  n,
) => n-points-on(xfrom, xto, n).zip(
  n-points-on(yfrom, yto, n),
  n-points-on(zfrom, zto, n),
)

#let render-lineparam((on-canvas, _, dim, ..x), elem) = {
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let points = n-points-on-cube(dim, steps).map(p => (elem.lineparam)(..p))
  // panic(points)
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

#let render-plane((on-canvas, ..x), elem) = {
  let elem-eval = eval-plane(elem)
  place(polygon(
    fill: elem-eval.fill,
    stroke: elem-eval.stroke,
    ..elem-eval
      .plane
      // .sorted(
      //   // FIXME:
      //   // hmm i guess i'm kinda fucked?
      //   // https://en.wikipedia.org/wiki/Graph_drawing
      //   // https://computergraphics.stackexchange.com/questions/1761/strategy-for-connecting-2-points-without-intersecting-previously-drawn-segments
      //   by: ((x1, y1, z1), (x2, y2, z2)) => {
      //     let dx = calc.abs(x2 - x1)
      //     let dy = calc.abs(y2 - y1)
      //     let dz = calc.abs(z2 - z1)
      //     return dx < dy or dy < dz
      //     if x1 > 0 and x2 > 0 {
      //       if y1 > 0 and y2 > 0 {
      //         return z1 > z2
      //       }
      //       return y1 > y2
      //     }
      //     return x1 > x2
      //   },
      // )
      .map(on-canvas),
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
        dx: if elem.kind == "z" { dx } else { dx - 6% },
        dy: dy,
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
          dx: if elem.kind == "z" { dx } else { dx - 2% },
          dy: dy,
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
  } else if "line" in elem {
    render-line(ctx, elem)
  } else if "lineparam" in elem {
    render-lineparam(ctx, elem)
  }
}
