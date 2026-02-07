#import "elem.typ": *
#import "linalg.typ": *
#import "canvas.typ": *
#import "eval.typ": *
#import "util.typ": *

// FIXME:
// https://en.wikipedia.org/wiki/Graph_drawing
// https://computergraphics.stackexchange.com/questions/1761/strategy-for-connecting-2-points-without-intersecting-previously-drawn-segments

// TODO: handle overflow on all elems


#let axis-tick-pos = (
  (dim, on-canvas, canvas-dim, map-point-pt),
  kind,
  position,
  from-3d,
  label-off,
  label,
  from-off: 0,
  to-off: 0,
  label-left-override: auto,
) => {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let relto = (min, max) => v => (v - min) / (max - min) * 100
  let reltox = relto(xmin, xmax)
  let reltoy = relto(ymin, ymax)
  let reltoz = relto(zmin, zmax)

  // TODO: parametarizeable positions other than "left/right"
  let label-left = {
    let (pos1, pos2) = position
    if kind == "z" {
      (
        (
          reltox(pos1) < 50 and reltox(pos1) <= reltoy(pos2)
        )
          or (
            reltoy(pos2) > 50 and reltox(pos1) <= reltoy(pos2)
          )
      )
    } else if kind == "x" {
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

  let (px, py, pz) = from-3d
  let to-3d = if label-left {
    if kind == "x" {
      (px, py - 1, pz)
    } else if kind == "y" {
      (px + 1, py, pz)
    } else {
      (px, py - 1, pz)
    }
  } else {
    if kind == "x" {
      (px, py + 1, pz)
    } else if kind == "y" {
      (px, py, pz - 1)
    } else {
      (px, py + 1, pz)
    }
  }
  let ((fx, fy), (tx, ty)) = (from-3d, to-3d).map(on-canvas).map(map-point-pt)
  let (nx, ny) = normalize-vec((tx - fx, ty - fy))
  let start = (fx - from-off * nx, fy - from-off * ny).map(i => i * 1pt)
  let end = (fx + to-off * nx, fy + to-off * ny).map(i => i * 1pt)

  let (sx, sy) = start
  let (dx, dy) = (sx - nx * label-off, sy - ny * label-off)
  let (width, height) = measure(label)
  (
    start: start,
    end: end,
    label-x: dx - width / 2,
    label-y: dy - height / 2,
    label-max: (
      dx - width,
      dx + width,
      dy - height,
      dy + height,
    ),
  )
}

// FIXME:
#let sort-by-distance(points, reference) = {
  points.sorted(key: p => distance-vec-squared(p, reference))
}
// #let sort-plane-chunks(points) = {
//   points
// .sorted(key: p => p)
// .fold((), (acc, (x, y, z)) => {
//   let arr = acc.find(r => r.at(0).at(0) == x)
//   if arr != none {
//     let pos = arr.position(((_, ay, _)) => ay > y)
//     arr.insert(if pos != none { pos } else { arr.len() }, (x, y, z))
//   } else {
//     let pos = acc.position(a => a.at(0).at(0) > x)
//     acc.insert(if pos != none { pos } else { acc.len() }, ((x, y, z),))
//   }
//   acc
// })
// }

// TODO:
#let render-clip-line(
  (on-canvas, out-of-bounds, dim, intersection-canvas),
  pts,
  stroke-param,
) = {
  let lines = ((),)
  let i = 0
  for p in pts {
    if out-of-bounds(p) {
      lines.at(i).push(p)
      i += 1
      lines.push((p,))
    } else {
      lines.at(i).push(p)
    }
  }
  // place(path-curve(stroke: elem.stroke, ..elem-eval.line.map(on-canvas)))
}
// TODO:
#let clip-plane(
  (out-of-bounds, dim, intersection-canvas),
  pts,
) = {
  // FIXME: wrong
  if pts.all(out-of-bounds) {
    ()
  }
  let points = if not pts.any(out-of-bounds) {
    pts
  } else {
    // FIXME: somewhat wrong
    let newpts = ()
    let prev-out = false
    let first-out = none
    for (i, p) in pts.enumerate() {
      if not out-of-bounds(p) {
        prev-out = false
        newpts.push(p)
        continue
      }
      if i == 0 {
        prev-out = true
        first-out = p
        continue
      }
      if not prev-out {
        prev-out = true
        newpts.push(intersection-canvas(newpts.last(), p))
      }
      if i == pts.len() - 1 {
        // TODO: probably wrong
        newpts.push(intersection-canvas(newpts.first(), p))
      } else if not out-of-bounds(pts.at(i + 1)) {
        newpts.push(intersection-canvas(pts.at(i + 1), p))
      }
    }
    if first-out != none {
      newpts.insert(0, intersection-canvas(newpts.last(), first-out))
    }
    newpts
  }
}
#let render-clip-plane(
  ctx,
  pts,
  stroke-param,
  fill-param,
) = {
  // FIXME: these points must be included if plane intersects
  let points = clip-plane(ctx, pts)
  // panic(pts, points)
  let p1 = points.at(0)
  place(polygon(
    stroke: apply-color-fn(p1, ..stroke-param),
    fill: apply-color-fn(p1, ..fill-param),
    ..points.map(ctx.on-canvas),
  ))
}

// TODO:
#let render-plane-points(
  ctx,
  points,
  stroke-param,
  fill-param,
) = {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  let z-out-of-bounds = ((_, _, z)) => z < zmin or z > zmax
  let z-plane = p => if p.at(2) > zmax { zmax } else { zmin }
  let r = points
  for (i, f) in r.slice(0, r.len() - 1).enumerate() {
    for (ii, ff) in f.slice(0, f.len() - 1).enumerate() {
      let p11 = ff
      let p12 = f.at(ii + 1)
      let p13 = r.at(i + 1).at(ii)

      let p21 = f.at(ii + 1)
      let p22 = r.at(i + 1).at(ii)
      let p23 = r.at(i + 1).at(ii + 1)

      for pts in ((p11, p12, p13), (p21, p22, p23)) {
        render-clip-plane(ctx, pts, stroke-param, fill-param)
        // if pts.all(out-of-bounds) {
        //   continue
        // }
        // let points = if pts.any(z-out-of-bounds) {
        //   let (overflow, ok) = pts.fold(((), ()), (
        //     (ov, ok),
        //     cur,
        //   ) => if z-out-of-bounds(cur) { ((..ov, cur), ok) } else {
        //     (ov, (..ok, cur))
        //   })
        //   if overflow.len() == 1 {
        //     let p = overflow.at(0)
        //     let z = z-plane(p)
        //     let (p1, p4) = ok
        //     (p1, z-intersection(z, p1, p), z-intersection(z, p4, p), p4)
        //   } else {
        //     let p = overflow.at(0)
        //     let z = z-plane(p)
        //     let pp = overflow.at(1)
        //     let zz = z-plane(pp)
        //     let (p1,) = ok
        //     (p1, z-intersection(z, p1, p), z-intersection(zz, p1, pp))
        //   }
        // } else {
        //   pts
        // }
        // let p1 = points.at(0)
        // place(polygon(
        //   stroke: apply-color-fn(p1, ..stroke-param),
        //   fill: apply-color-fn(p1, ..fill-param),
        //   ..points.map(on-canvas),
        // ))
      }
    }
  }
}

#let render-planeparam(
  ctx,
  elem,
) = {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let p-x-y = x-y-points(ctx.dim, steps)
  let p-x-y-z = p-x-y.map(ps => ps.map(((x, y)) => (
    x,
    y,
    (elem.planeparam)(x, y),
  )))
  render-plane-points(
    ctx,
    // FIXME:
    p-x-y-z,
    (elem.stroke-color-fn, elem.stroke),
    (elem.fill-color-fn, elem.fill),
  )
}

#let render-lineparam((on-canvas, dim, out-of-bounds, ..x), elem) = {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let points = n-points-on-cube(dim, steps).map(p => (elem.lineparam)(..p))
  // TODO: handle out of bounds better
  for ps in points.filter(p => not out-of-bounds(p)).windows(2) {
    place(path-curve(
      stroke: apply-color-fn(ps.at(0), elem.stroke-color-fn, elem.stroke),
      ..ps.map(on-canvas),
    ))
  }
}

#let render-line(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let elem-eval = eval-line(ctx, elem)
  if elem-eval.line.len() > 1 {
    place(path-curve(stroke: elem.stroke, ..elem-eval.line.map(on-canvas)))
  } else {
    // TODO: warn
  }
}

#let render-planeplot(ctx, elem) = {
  let (dim, on-canvas) = ctx
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let (x, y, z, num) = elem.planeplot
  let points = x.zip(y, z)
  if num != none {
    // TODO:
    render-plane-points(
      ctx,
      points.chunks(num),
      (elem.stroke-color-fn, elem.stroke),
      (elem.fill-color-fn, elem.fill),
    )
  } else {
    // TODO:
    place(polygon(
      fill: elem.fill,
      stroke: elem.stroke,
      // ..connect-circle-2d(..points.map(on-canvas)),
      ..points.map(on-canvas),
    ))
  }

  // render-plane-points(
  //   ctx,
  //   // FIXME:
  //   sort-by-distance(points),
  //   p => elem.stroke,
  //   p => elem.fill,
  // )
  // for triangle in points.windows(3) {
  //   place(polygon(
  //     fill: elem.fill,
  //     stroke: elem.stroke,
  //     ..triangle.map(on-canvas),
  //   ))
  // }
}

#let render-lineplot(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let (x, y, z) = elem.lineplot
  let points = x.zip(y, z)
  // TODO: overflow
  place(path-curve(stroke: elem.stroke, ..points.map(on-canvas)))
}

#let render-path((on-canvas, ..x), elem) = {
  place(path-curve(stroke: elem.stroke, ..elem.path.map(on-canvas)))
}

#let render-polygon(ctx, elem) = {
  // place(polygon(
  //   fill: elem.fill,
  //   stroke: elem.stroke,
  //   ..elem.polygon.map(on-canvas),
  // ))
  render-clip-plane(
    ctx,
    elem.polygon,
    (none, elem.stroke),
    (none, elem.fill),
  )
}

#let render-plane(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let elem-eval = eval-plane(ctx, elem)
  if elem-eval.plane.len() > 2 {
    place(polygon(
      fill: elem-eval.fill,
      stroke: elem-eval.stroke,
      ..connect-circle-2d(..elem-eval.plane.map(on-canvas)),
    ))
  } else {
    // TODO: warn
  }
}

#let render-tip((on-canvas, map-point-pt), tip, start, end, stroke) = {
  let ptstart = map-point-pt(start)
  let ptend = map-point-pt(end)
  if type(tip) == function {
    let (x, y) = end
    let mark = tip(stroke, end)
    let (width, height) = measure(mark)
    place(dx: x - width / 2, dy: y - height / 2, mark)
  } else {
    let (x, y) = ptend
    let d = map-point-pt(direction-vec(end, start))
    let theta = atan2(..d.rev())
    let phi = calc.pi / 6
    let (l1, l2) = (theta + phi, theta - phi).map(a => (
      (x + 5 * calc.sin(a)) * 1pt,
      (y + 5 * calc.cos(a)) * 1pt,
    ))
    if tip == ">" {
      place(path-curve(stroke: stroke, l1, end, l2))
    } else if tip == "|>" {
      place(polygon(stroke: stroke, fill: stroke, l1, end, l2))
    } else if tip == "|" {
      let (f, t) = perpendicular-2d(
        ptstart,
        ptend,
        ptend,
        6,
      ).map(v => v.map(i => i * 1pt))
      place(line(stroke: stroke, start: f, end: t))
    }
  }
}

#let render-vec(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let (start, end) = elem.vec.map(on-canvas)
  if elem.toe != none {
    render-tip(ctx, elem.toe, end, start, elem.stroke)
  }
  if elem.tip != none {
    render-tip(ctx, elem.tip, start, end, elem.stroke)
  }
  place(line(
    stroke: elem.stroke,
    start: start,
    end: end,
  ))
}

#let render-axis(ctx, elem) = {
  let (on-canvas, canvas-dim, dim, out-of-bounds, axes) = ctx
  let (xas, yas, zas) = axes
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim

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

  let axis-ticks = a => {
    let axis = a
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
    if axis == none { () }
    let (kind, ticks, nticks) = axis
    let h = axis-helper-fn(ctx, axis)
    let tmin = h.min
    let tmax = h.max
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

  // TODO: better auto ticks
  let xticks = axis-ticks(xas)
  let yticks = axis-ticks(yas)
  let zticks = axis-ticks(zas)

  let pmin = point(min)
  let pmax = point(max)
  let place-line = (start, end, stroke: elem.plane.stroke) => place(line(
    stroke: stroke,
    start: on-canvas(start),
    end: on-canvas(end),
  ))
  let line-from = point-n(elem.line.position, min)
  let line-to = point-n(elem.line.position, max)
  if not elem.plane.hidden {
    place(polygon(
      fill: elem.plane.fill,
      stroke: elem.plane.stroke,
      ..plane-points.map(on-canvas),
    ))
  }

  if not elem.line.hidden {
    // TODO: show label if line hidden
    if elem.label != none {
      let from-3d = mid(line-from, line-to)
      // FIXME: depends on tick label & offset
      let loff = 1em.to-absolute().pt() * 3.5pt

      let (label-x, label-y) = axis-tick-pos(
        ctx,
        elem.kind,
        elem.line.position,
        mid(line-from, line-to),
        loff,
        elem.label,
      )

      place(
        dx: label-x,
        dy: label-y,
        elem.label,
      )
    }

    // TODO: tip, toe
    place-line(line-from, line-to, stroke: elem.line.stroke)
  }
  if elem.format-ticks != none {
    // if elem.format-subticks != none {}
    let (length, offset) = elem.format-ticks
    let from = ((length / 2) + offset) / 1pt
    let to = ((length / 2) - offset) / 1pt
    if not elem.line.hidden {
      for tick in elem.ticks {
        let loff = 1em.to-absolute().pt() * 1pt
        let label = (elem.format-ticks.label-format)(tick)
        let (start, end, label-x, label-y) = axis-tick-pos(
          ctx,
          elem.kind,
          elem.line.position,
          point-r(line-from, tick),
          loff,
          label,
          from-off: from,
          to-off: to,
        )

        place(line(
          stroke: elem.format-ticks.stroke,
          start: start,
          end: end,
        ))
        place(
          dx: label-x,
          dy: label-y,
          label,
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
  } else if "planeplot" in elem {
    render-planeplot(ctx, elem)
  } else if "vec" in elem {
    render-vec(ctx, elem)
  } else if "line" in elem {
    render-line(ctx, elem)
  } else if "lineparam" in elem {
    render-lineparam(ctx, elem)
  } else if "lineplot" in elem {
    render-lineplot(ctx, elem)
  }
}

#let label-img(elem, height) = {
  // TODO: parametric fn colors
  box(width: 1em, height: height, place(horizon + center, if "polygon" in elem
    or "plane" in elem
    or "planeplot" in elem
    or "planeparam" in elem {
    rect(width: 1em, height: height, stroke: elem.stroke, fill: elem.fill)
  } else if (
    "path" in elem
      or "vec" in elem
      or "line" in elem
      or "lineparam" in elem
      or "lineplot" in elem
  ) {
    line(length: 1em, stroke: elem.stroke)
  }))
}

#let render-legend(
  ctx,
  legend-params,
  legend-elems,
) = {
  let (dir, position, label-format, stroke, fill) = legend-params
  let content = legend-elems.map(elem => [
    #let lbl = label-format(elem.label)
    #label-img(elem, measure(lbl).height) #lbl
  ])
  place(
    position,
    block(
      inset: 1em / 4,
      fill: fill,
      stroke: stroke,
      stack(spacing: 1em / 2, dir: dir, ..content),
    ),
  )
}
