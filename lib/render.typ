#import "elem.typ": *
#import "linalg.typ": *
#import "canvas.typ": *
#import "eval.typ": *

// FIXME:
// https://en.wikipedia.org/wiki/Graph_drawing
// https://computergraphics.stackexchange.com/questions/1761/strategy-for-connecting-2-points-without-intersecting-previously-drawn-segments

#let z-intersection = (z, (x1, y1, z1), (x2, y2, z2)) => {
  let t = (z - z1) / (z2 - z1)
  (x1 + t * (x2 - x1), y1 + t * (y2 - y1), z1 + t * (z2 - z1))
}

#let n-points-on = (min, max, n) => range(0, n + 1).map(i => (
  min + i * ((max - min) / n)
))
// why did i do this exactly?
#let n-points-on-cube = (
  ((xmin, xmax), (ymin, ymax), (zmin, zmax)),
  n,
) => n-points-on(xmin, xmax, n).zip(
  n-points-on(ymin, ymax, n),
  n-points-on(zmin, zmax, n),
)
#let x-y-points = (((xmin, xmax), (ymin, ymax), ..x), n) => n-points-on(
  xmin,
  xmax,
  n,
).map(x => n-points-on(ymin, ymax, n).map(y => (x, y)))

#let apply-color-fn = (p, fn, def) => if fn != none { fn(..p) } else { def }

#let render-planeparam(
  (on-canvas, dim, out-of-bounds, clamp-to-bounds, ..x),
  elem,
) = {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let p-x-y = x-y-points(dim, steps)
  let p-x-y-z = p-x-y.map(pa => pa.map(((x, y)) => (
    x,
    y,
    (elem.planeparam)(x, y),
  )))

  let z-out-of-bounds = ((_, _, z)) => z < zmin or z > zmax
  let z-plane = p => if p.at(2) > zmax { zmax } else { zmin }
  let r = p-x-y-z.rev()
  for (i, f) in r.slice(0, r.len() - 1).enumerate() {
    for (ii, ff) in f.slice(0, f.len() - 1).enumerate() {
      let p11 = ff
      let p12 = f.at(ii + 1)
      let p13 = r.at(i + 1).at(ii)

      let p21 = f.at(ii + 1)
      let p22 = r.at(i + 1).at(ii)
      let p23 = r.at(i + 1).at(ii + 1)

      for pts in ((p11, p12, p13), (p21, p22, p23)) {
        if pts.all(out-of-bounds) {
          continue
        }
        if pts.any(z-out-of-bounds) {
          let (overflow, ok) = pts.fold(((), ()), (
            (ov, ok),
            cur,
          ) => if z-out-of-bounds(cur) { ((..ov, cur), ok) } else {
            (ov, (..ok, cur))
          })
          if overflow.len() == 1 {
            let p = overflow.at(0)
            let z = z-plane(p)
            let (p1, p4) = ok

            place(polygon(
              stroke: apply-color-fn(p1, elem.stroke-color-fn, elem.stroke),
              fill: apply-color-fn(p1, elem.fill-color-fn, elem.fill),
              on-canvas(p1),
              on-canvas(z-intersection(z, p1, p)),
              on-canvas(z-intersection(z, p4, p)),
              on-canvas(p4),
            ))
          } else {
            let p = overflow.at(0)
            let z = z-plane(p)
            let pp = overflow.at(1)
            let zz = z-plane(pp)

            let (p1,) = ok

            place(polygon(
              stroke: apply-color-fn(p1, elem.stroke-color-fn, elem.stroke),
              fill: apply-color-fn(p1, elem.fill-color-fn, elem.fill),
              on-canvas(p1),
              on-canvas(z-intersection(z, p1, p)),
              on-canvas(z-intersection(zz, p1, pp)),
            ))
          }
        } else {
          let (p1, p2, p3) = pts
          place(polygon(
            stroke: apply-color-fn(p1, elem.stroke-color-fn, elem.stroke),
            fill: apply-color-fn(p1, elem.fill-color-fn, elem.fill),
            on-canvas(p1),
            on-canvas(p2),
            on-canvas(p3),
          ))
        }
      }
    }
  }
}

#let render-lineparam((on-canvas, dim, out-of-bounds, ..x), elem) = {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let points = n-points-on-cube(dim, steps).map(p => (elem.lineparam)(..p))
  if elem.label != none {
    let (dx, dy) = on-canvas(points.last())
    place(dx: dx, dy: dy, elem.label)
  }
  // TODO: handle out of bounds better
  for ps in points.filter(p => not out-of-bounds(p)).windows(2) {
    place(path(
      stroke: apply-color-fn(ps.at(0), elem.stroke-color-fn, elem.stroke),
      ..ps.map(on-canvas),
    ))
  }
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

#let render-vec((on-canvas, ..x), elem) = {
  if elem.label != none {
    let (dx, dy) = on-canvas(elem.vec.at(1))
    place(dx: dx, dy: dy, elem.label)
  }

  place(line(
    stroke: elem.stroke,
    start: on-canvas(elem.vec.at(0)),
    end: on-canvas(elem.vec.at(1)),
  ))
}

#let render-axis(ctx, elem) = {
  let (on-canvas, dim, out-of-bounds, _, (xas, yas, zas), _) = ctx
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim

  let axis-ticks = (kind: "x", ticks: auto, nticks: auto, ..x) => {
    let (tmax, tmin) = if kind == "x" {
      (xmax, xmin)
    } else if kind == "y" {
      (ymax, ymin)
    } else {
      (zmax, zmin)
    }
    let span = tmax - tmin
    if (
      ticks == auto and nticks == auto
    ) {
      n-points-on(tmin, tmax, 10)
    } else if ticks == auto {
      n-points-on(tmin, tmax, nticks)
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
    if ax == none { () } else { axis-ticks(..ax) }
  }

  let xticks = first-tick-axis(xas)
  let yticks = first-tick-axis(yas)
  let zticks = first-tick-axis(zas)

  let (
    point,
    point-p,
    point-r,
    point-n,
    cur,
    min,
    max,
    plane-points,
  ) = axis-helper-fn(
    ctx,
    elem,
  )

  let pmin = point(min)
  let pmax = point(max)
  let place-line = (start, end, stroke: elem.plane.stroke) => place(line(
    stroke: stroke,
    start: on-canvas(start),
    end: on-canvas(end),
  ))
  let mid = (f, s) => f.enumerate().map(((i, n)) => (s.at(i) + n) / 2)
  let line-from = point-n(elem.line.position, min)
  let line-to = point-n(elem.line.position, max)
  if not elem.plane.hidden {
    render-polygon(
      ctx,
      polygon3d(
        ..plane-points,
        stroke: elem.plane.stroke,
        fill: elem.plane.fill,
      ),
    )
    // render-plane(ctx, plane3d(
    //   pmax,
    //   elem.position,
    //   stroke: elem.stroke,
    //   fill: elem.fill,
    // ))
  }

  let relto = (min, max) => v => (v - min) / (max - min) * 100
  let reltox = relto(xmin, xmax)
  let reltoy = relto(ymin, ymax)
  let reltoz = relto(zmin, zmax)

  let label-left = {
    // TODO: comparison must be relative
    let (pos1, pos2) = elem.line.position
    if elem.kind == "z" {
      (
        (
          reltox(pos1) < 50 and reltox(pos1) <= reltoy(pos2)
        )
          or (
            reltoy(pos2) > 50 and reltox(pos1) <= reltoy(pos2)
          )
      )
    } else if elem.kind == "x" {
      (
        (
          reltoy(pos1) > 50 and reltoy(pos1) >= 100 - reltoz(pos2)
        )
          or (
            reltoz(pos2) > 50 and 100 - reltoy(pos1) <= reltoz(pos2)
          )
      )
    } else {
      (
        (
          reltox(pos1) < 50 and reltox(pos1) <= 100 - reltoz(pos2)
        )
          or (
            reltoz(pos2) < 50 and reltox(pos1) <= 100 - reltoz(pos2)
          )
      )
    }
  }

  if not elem.line.hidden {
    let (dx, dy) = on-canvas(mid(line-from, line-to))
    if elem.label != none {
      // FIXME:
      let (dx2, dy2) = if label-left {
        if elem.kind == "x" {
          (dx - 20pt, dy - 48pt)
        } else if elem.kind == "y" {
          (dx - 36pt, dy + 5pt)
        } else {
          (dx - 56pt, dy - 10pt)
        }
      } else {
        if elem.kind == "x" {
          (dx + 5pt, dy - 2pt)
        } else if elem.kind == "y" {
          (dx - 20pt, dy - 48pt)
        } else {
          (dx + 14pt, dy - 10pt)
        }
      }
      // FIXME:
      place(
        dx: dx2,
        dy: dy2,
        pad(16pt, elem.label),
      )
    }
    // TODO: tip, toe
    place-line(line-from, line-to, stroke: elem.line.stroke)
  }
  if elem.format-ticks != none {
    let ticks = ()
    if type(elem.ticks) == array {
      ticks = elem.ticks.filter(t => t <= max and t >= min)
    } else {
      let nticks = if elem.nticks == auto {
        (max - min) / 10
      } else { elem.nticks }
      ticks = range(0, int((max - min) / nticks) + 1).map(i => (
        min + i * nticks
      ))
    }

    // if elem.format-subticks != none {}

    let (length, offset) = elem.format-ticks
    let from = (length / 2) + offset
    let to = (length / 2) - offset
    if not elem.line.hidden {
      for tick in ticks {
        let (px, py, pz) = point-r(line-from, tick)
        let (start, end) = (
          if label-left {
            if elem.kind == "x" {
              ((px, py, pz - from), (px, py, pz + to))
            } else if elem.kind == "y" {
              ((px - from, py, pz), (px + to, py, pz))
            } else {
              ((px - from, py, pz), (px + to, py, pz))
            }
          } else {
            if elem.kind == "x" {
              ((px, py - from, pz), (px, py + to, pz))
            } else if elem.kind == "y" {
              ((px, py, pz - from), (px, py, pz + to))
            } else {
              ((px, py + from, pz), (px, py - to, pz))
            }
          }
        ).map(on-canvas)

        place(line(
          stroke: elem.format-ticks.stroke,
          start: start,
          end: end,
        ))
        let (sx, sy) = start
        let (ex, ey) = end
        // FIXME:
        let (dx, dy) = if label-left {
          if elem.kind == "x" {
            (ex - 4pt, ey - 10pt)
          } else if elem.kind == "y" {
            (sx - 14pt, sy + 2pt)
          } else {
            (sx - 16pt, sy - 2pt)
          }
        } else {
          if elem.kind == "x" {
            (sx + 4pt, sy + 2pt)
          } else if elem.kind == "y" {
            (ex - 4pt, ey - 10pt)
          } else {
            (ex + 2pt, ey - 2pt)
          }
        }
        place(
          dx: dx,
          dy: dy,
          (elem.format-ticks.label-format)(tick),
        )
      }
    }
    if not elem.plane.hidden {
      if elem.kind == "z" {
        for tick in xticks {
          place-line(
            (tick, ymin, elem.plane.position),
            (tick, ymax, elem.plane.position),
          )
        }
        for tick in yticks {
          place-line(
            (xmin, tick, elem.plane.position),
            (xmax, tick, elem.plane.position),
          )
        }
      } else if elem.kind == "y" {
        for tick in xticks {
          place-line(
            (tick, elem.plane.position, zmin),
            (tick, elem.plane.position, zmax),
          )
        }
        for tick in zticks {
          place-line(
            (xmin, elem.plane.position, tick),
            (xmax, elem.plane.position, tick),
          )
        }
      } else {
        for tick in yticks {
          place-line(
            (elem.plane.position, tick, zmin),
            (elem.plane.position, tick, zmax),
          )
        }
        for tick in zticks {
          place-line(
            (elem.plane.position, ymin, tick),
            (elem.plane.position, ymax, tick),
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
  } else if "vec" in elem {
    render-vec(ctx, elem)
  } else if "lineparam" in elem {
    render-lineparam(ctx, elem)
  }
}
