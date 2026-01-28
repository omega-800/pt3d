#import "elem.typ": *
#import "linalg.typ": *

#let render-path((dim, on-canvas), elem) = {
  place(path(stroke: elem.stroke, ..elem.path.map(on-canvas)))
}

#let render-polygon((dim, on-canvas), elem) = {
  place(polygon(
    fill: elem.fill,
    stroke: elem.stroke,
    ..elem.polygon.map(on-canvas),
  ))
}

#let render-plane((dim, on-canvas), elem) = {
  let ((a, b, c), d) = elem.plane
  let points = ()
  for ((x1, y1, z1), (x2, y2, z2)) in cube-edges(dim) {
    let denom = (a * (x2 - x1) + b * (y2 - y1) + c * (z2 - z1))
    if denom == 0 {
      continue
    }
    let t = (
      -(a * x1 + b * y1 + c * z1 + d) / denom
    )
    if t >= 0 and t <= 1 {
      points.push((
        (1 - t) * x1 + t * x2,
        (1 - t) * y1 + t * y2,
        (1 - t) * z1 + t * z2,
      ))
    }
  }

  place(polygon(
    fill: elem.fill,
    stroke: elem.stroke,
    ..points
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
      // FIXME: is reversed
      .map(on-canvas),
  ))
}

#let render-line((dim, on-canvas), elem) = {
  if elem.label != none {
    let (dx, dy) = on-canvas(elem.line.at(1))
    place(dx: dx, dy: dy, elem.label)
  }

  place(line(
    stroke: elem.stroke,
    start: on-canvas(elem.line.at(0)),
    end: on-canvas(
      elem.line.at(1),
    ),
  ))
}

#let render-axis(render, ctx, elem) = {
  let (dim, on-canvas) = ctx
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim
  let (point, point-p, cur, from, to) = if elem.kind == "x" {
    (
      x => (x, 0, 0),
      ((x, y, z), n) => (x, y + n, z + n),
      ((x, y, z)) => x,
      xfrom,
      xto,
    )
  } else if elem.kind == "y" {
    (
      y => (0, y, 0),
      ((x, y, z), n) => (x + n, y, z + n),
      ((x, y, z)) => y,
      yfrom,
      yto,
    )
  } else {
    (
      z => (0, 0, z),
      ((x, y, z), n) => (x + n, y + n, z),
      ((x, y, z)) => z,
      zfrom,
      zto,
    )
  }
  if not elem.line.hidden {
    let (dx, dy) = on-canvas(point(to))
    let (from, to) = dim.at(if elem.kind == "x" {
      0
    } else if elem.kind == "y" {
      1
    } else {
      2
    })
    if elem.label != none {
      place(dx: dx, dy: dy, elem.label)
    }
    // TODO: tip, toe, position
    place(line(
      stroke: elem.stroke,
      start: on-canvas(point(from)),
      end: on-canvas(point(to)),
    ))
  }
  if not elem.plane.hidden {
    render-plane(ctx, plane3d(
      point(to),
      // FIXME: is reversed, fix plane3d render
      -elem.position,
      stroke: elem.stroke,
      fill: elem.fill,
    ))
  }
  if elem.format-ticks != none {
    let ticks = ()
    if type(elem.ticks) == array {
      ticks = elem.ticks.filter(t => t <= to and t >= from)
    } else {
      let tick-distance = if elem.tick-distance == auto {
        (to - from) / 10
      } else { elem.tick-distance }
      ticks = range(0, int((to - from) / tick-distance)).map(i => (
        from + i * tick-distance
      ))
    }

    // if elem.format-subticks != none {}
    if not elem.line.hidden {
      for tick in ticks {
        let tick-point = point(tick)
        place(line(
          // TODO: tick-args
          stroke: elem.stroke,
          start: on-canvas(point-p(tick-point, -0.1)),
          end: on-canvas(point-p(tick-point, 0.1)),
        ))
        let (dx, dy) = on-canvas(point-p(tick-point, 0.1))
        place(dx: dx, dy: dy, text(size: 0.75em)[#calc.round(tick, digits: 2)])
      }
    }
    let pos-grd = (start, fst, cur-t) => {
      let coord = (
        elem.position,
        if start { to } else { -to },
        cur-t,
      )
      on-canvas((
        if elem.kind == "x" and fst {
          (0, 1, 2)
        } else if elem.kind == "x" {
          (0, 2, 1)
        } else if elem.kind == "y" and fst {
          (2, 0, 1)
        } else if elem.kind == "y" {
          (1, 0, 2)
        } else if elem.kind == "z" and fst {
          (1, 2, 0)
        } else {
          (2, 1, 0)
        }
      ).map(i => coord.at(i)))
    }
    if not elem.plane.hidden {
      for tick in ticks {
        let tick-point = point(tick)
        let cur-t = cur(tick-point)
        place(line(
          stroke: elem.stroke,
          start: pos-grd(true, true, cur-t),
          end: pos-grd(false, true, cur-t),
        ))
        place(line(
          stroke: elem.stroke,
          start: pos-grd(true, false, cur-t),
          end: pos-grd(false, false, cur-t),
        ))
      }
    }
  }
}

#let render = (
  ctx,
  elem,
) => {
  if "axis" in elem {
    render-axis((..x) => [], ctx, elem)
  } else if "path" in elem {
    render-path(ctx, elem)
  } else if "polygon" in elem {
    render-polygon(ctx, elem)
  } else if "plane" in elem {
    render-plane(ctx, elem)
  } else if "line" in elem {
    render-line(ctx, elem)
  }
}
#let render-axis = render-axis.with(render)
