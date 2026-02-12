#import "elem.typ": *
#import "linalg.typ": *
#import "canvas.typ": *
#import "eval.typ": *
#import "util.typ": *
#import "axes.typ": *
#import "clip.typ": *
#import "mark.typ": *

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
    if "eval-marks" in elem and elem.eval-marks != none {
      for mark in elem.eval-marks {
        render-mark(ctx, mark)
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
  }
}

#let render-vec(ctx, elem) = {
  let (on-canvas, ..x) = ctx
  let (start, end) = elem.eval-points.at(0)
  if elem.eval-toe != none {
    render-mark(ctx, elem.eval-toe)
  }
  if elem.eval-tip != none {
    render-mark(ctx, elem.eval-tip)
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

  if elem.eval-tip != none {
    render-mark(ctx, elem.eval-tip)
  }
  if elem.eval-toe != none {
    render-mark(ctx, elem.eval-toe)
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
  "axis": render-axes,
  "lineaxis": render-axisline,
  "planeaxis": render-axisplane,
  "plane": render-plane,
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
