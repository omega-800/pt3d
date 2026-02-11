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

#let render-label((on-canvas, ..x), (label, position)) = {
  let (dx, dy) = on-canvas(position)
  let (width, height) = measure(label)
  place(
    dx: dx - width / 2,
    dy: dy - height / 2,
    label,
  )
}

#let render-tip(ctx, tip, start, end, stroke) = {
  let (on-canvas, map-point-pt, pt-to-ratio) = ctx
  let c-start = on-canvas(start)
  let c-end = on-canvas(end)
  let ptstart = map-point-pt(c-start)
  let ptend = map-point-pt(c-end)
  if type(tip) == function {
    render-label(ctx, (label: tip(stroke, end), position: end))
  } else {
    let (x, y) = ptend
    let d = map-point-pt(direction-vec(c-end, c-start))
    let theta = atan2(..d.rev())
    let phi = calc.pi / 6
    let (l1, l2) = (theta + phi, theta - phi).map(a => pt-to-ratio(
      ((x + 5 * calc.sin(a)) * 1pt, (y + 5 * calc.cos(a)) * 1pt),
    ))
    if tip == ">" {
      place(path-curve(stroke: stroke, l1, c-end, l2))
    } else if tip == "|>" {
      place(polygon(stroke: stroke, fill: stroke, l1, c-end, l2))
    } else if tip == "|" {
      let (f, t) = perpendicular-2d(
        ptstart,
        ptend,
        ptend,
        6,
      ).map(v => pt-to-ratio(v.map(i => i * 1pt)))
      place(line(stroke: stroke, start: f, end: t))
    }
  }
}

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
    if "mark" in elem and elem.mark != none {
      // TODO: color-fn
      for (from, to) in points.windows(2) {
        let stroke = if stroke-param.at(0) == none { stroke-param.at(1) } else {
          apply-color-fn(from, ..stroke-param)
        }
        render-tip(ctx, elem.mark, from, to, stroke)
      }
      // for point in points {
      //   let mark = if type(elem.mark) == function {
      //     (elem.mark)(point, elem.stroke)
      //   } else {
      //     elem.mark
      //   }
      //   render-label(ctx, (label: mark, position: point))
      // }
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

#let render-vec(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let (start, end) = elem.eval-points.at(0)
  if elem.toe != none {
    render-tip(ctx, elem.toe, end, start, elem.stroke)
  }
  if elem.tip != none {
    render-tip(ctx, elem.tip, start, end, elem.stroke)
  }
  place(line(
    stroke: elem.stroke,
    start: on-canvas(start),
    end: on-canvas(end),
  ))
}

#let render-ticks(ctx, ticks) = {
  let (on-canvas, ..x) = ctx
  for (label, tick, stroke) in ticks {
    let (start, end) = tick
    place(line(
      stroke: stroke,
      start: on-canvas(start),
      end: on-canvas(end),
    ))
    if label != none {
      render-label(ctx, label)
    }
  }
}

#let render-axisline(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let (start, end) = elem.eval-points

  place(line(start: on-canvas(start), end: on-canvas(end), stroke: elem.stroke))

  if elem.tip != none {
    render-tip(ctx, elem.tip, start, end, elem.stroke)
  }
  if elem.toe != none {
    render-tip(ctx, elem.toe, end, start, elem.stroke)
  }

  if elem.eval-label != none {
    render-label(ctx, elem.eval-label)
  }
  render-ticks(ctx, elem.eval-ticks)
}

#let render-axisplane(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  place(polygon(
    fill: elem.fill,
    stroke: elem.stroke,
    ..elem.eval-points.map(on-canvas),
  ))
  if elem.eval-label != none {
    render-label(ctx, elem.eval-label)
  }
  render-ticks(ctx, elem.eval-ticks)
}

#let render-axes(ctx, axis) = {
  for i in axis.instances {
    if i.type == "axisline" {
      render-axisline(ctx, i)
    } else {
      render-axisplane(ctx, i)
    }
  }
}

#let render = (
  // TODO:
  "axis": render-axes,
  "lineaxis": render-axisline,
  "planeaxis": render-axisplane,
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
  width: auto,
  height: auto,
) = {
  let (dir, position, label, stroke, fill, spacing, inset) = legend-params
  let content = legend-elems.map(elem => render-legend-label(elem, label))
  block(
    inset: inset,
    fill: fill,
    stroke: stroke,
    width: width,
    height: height,
    stack(spacing: spacing, dir: dir, ..content),
  )
}
