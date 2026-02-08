#import "elem.typ": *
#import "linalg.typ": *
#import "canvas.typ": *
#import "eval.typ": *
#import "util.typ": *
#import "axes.typ": *
#import "clip.typ": *

// FIXME:
// https://en.wikipedia.org/wiki/Graph_drawing
// https://computergraphics.stackexchange.com/questions/1761/strategy-for-connecting-2-points-without-intersecting-previously-drawn-segments

#let render-clipped-line(
  ctx,
  elem,
) = {
  let stroke-param = (
    if "stroke-color-fn" in elem { elem.stroke-color-fn } else { none },
    elem.stroke,
  )
  for points in elem.eval-points {
    if points.len() < 2 {
      continue
    }
    if stroke-param.at(0) == none {
      place(path-curve(stroke: stroke-param.at(1), ..points.map(
        ctx.on-canvas,
      )))
    } else {
      for sub-pts in points.windows(2) {
        place(line(
          stroke: apply-color-fn(sub-pts.at(0), ..stroke-param),
          start: (ctx.on-canvas)(sub-pts.at(0)),
          end: (ctx.on-canvas)(sub-pts.at(1)),
        ))
      }
    }
  }
}

#let render-clipped-plane(
  ctx,
  elem,
) = {
  let stroke-param = (
    if "stroke-color-fn" in elem { elem.stroke-color-fn } else { none },
    elem.stroke,
  )
  let fill-param = (
    if "fill-color-fn" in elem { elem.fill-color-fn } else { none },
    elem.fill,
  )
  for points in elem.eval-points {
    if points.len() == 0 {
      // panic(pts, points)
    } else {
      let p1 = points.at(0)
      place(polygon(
        stroke: apply-color-fn(p1, ..stroke-param),
        fill: apply-color-fn(p1, ..fill-param),
        ..points.map(ctx.on-canvas),
      ))
    }
  }
}

#let render-plane(ctx, elem) = {
  let pts = elem.eval-points.at(0)
  if pts.len() > 2 {
    place(polygon(
      fill: elem.fill,
      stroke: elem.stroke,
      ..connect-circle-2d(..pts.map(ctx.on-canvas)),
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
  let (start, end) = elem.eval-points.at(0).map(on-canvas)
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
      let from-3d = mid-vec(line-from, line-to)
      // FIXME: depends on tick label & offset
      let loff = 1em.to-absolute().pt() * 3.5pt

      let (label-x, label-y) = axis-tick-pos(
        ctx,
        elem.kind,
        elem.line.position,
        mid-vec(line-from, line-to),
        loff,
        elem.label,
      )

      place(
        dx: label-x,
        dy: label-y,
        elem.label,
      )
    }

    let c-l-from = on-canvas(line-from)
    let c-l-to = on-canvas(line-to)
    // TODO: tip, toe
    if elem.line.tip != none {
      render-tip(ctx, elem.line.tip, c-l-from, c-l-to, elem.line.stroke)
    }
    if elem.line.toe != none {
      render-tip(ctx, elem.line.toe, c-l-to, c-l-from, elem.line.stroke)
    }
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
  // TODO:
  "axis": render-axis,
  // TODO:
  "plane": render-plane,
  // TODO:
  "vec": render-vec,
  "vertices": render-clipped-plane,
  "polygon": render-clipped-plane,
  "planeplot": render-clipped-plane,
  "planeparam": render-clipped-plane,
  "lineplot": render-clipped-line,
  "lineparam": render-clipped-line,
  "line": render-clipped-line,
  "path": render-clipped-line,
)

#let render-legend-label(elem, (width, format, dir, spacing)) = {
  let stroke = elem.stroke
  let fill = none
  let height = measure(format(elem.label, black, black)).height
  let image = if (
    elem.type in ("polygon", "plane", "planeplot", "vertices", "planeparam")
  ) {
    fill = elem.fill
    if (
      "stroke-color-fn" in elem and type(elem.stroke-color-fn) == function
        or "fill-color-fn" in elem and type(elem.stroke-color-fn) == function
    ) {
      let pts = elem.eval-points.join()
      let (min, max) = pts.fold((pts.at(0), pts.at(0)), minmax-vec)
      if "stroke-color-fn" in elem {
        stroke = gradient.linear(
          (elem.stroke-color-fn)(..min),
          (elem.stroke-color-fn)(..max),
        )
      }
      if "fill-color-fn" in elem {
        fill = gradient.linear(
          (elem.fill-color-fn)(..min),
          (elem.fill-color-fn)(..max),
        )
      }
    }
    rect(width: width, height: height, stroke: stroke, fill: fill)
  } else if (
    elem.type
      in (
        "path",
        "vec",
        "line",
        "lineparam",
        "lineplot",
      )
  ) {
    let stroke = elem.stroke
    if "stroke-color-fn" in elem and type(elem.stroke-color-fn) == function {
      let pts = elem.eval-points.join()
      let (min, max) = pts.fold((pts.at(0), pts.at(0)), minmax-vec)
      stroke = gradient.linear(
        (elem.stroke-color-fn)(..min),
        (elem.stroke-color-fn)(..max),
      )
    }
    line(length: 1em, stroke: stroke)
  }
  let lbl = format(elem.label, stroke, fill)
  stack(
    dir: dir,
    spacing: spacing,
    box(width: width, height: height, place(horizon + center, image)),
    lbl,
  )
}

#let render-legend(
  ctx,
  legend-params,
  legend-elems,
) = {
  let (dir, position, label, stroke, fill, spacing, inset) = legend-params
  let content = legend-elems.map(elem => render-legend-label(elem, label))
  block(
    inset: inset,
    fill: fill,
    stroke: stroke,
    stack(spacing: spacing, dir: dir, ..content),
  )
}
