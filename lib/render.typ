#import "linalg.typ": *
#import "canvas.typ": *
#import "eval.typ": *
#import "util.typ": *
#import "axes.typ": *
#import "clip.typ": *
#import "mark.typ": *


#let render-marks(ctx, elem) = {
  if "eval-marks" in elem and elem.eval-marks != none {
    for mark in elem.eval-marks {
      // FIXME: render marks that are in front of the plane
      render-mark(ctx, mark)
    }
  }
}

/// Renders a @lineplot, @path, @line or @quiver element: draws the (clipped)
/// polylines, applying the `stroke-color-fn` gradient, and the marks.
///
/// -> content
#let render-clipped-line(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Element with evaluated `eval-points`
  /// -> dictionary
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
        // TODO: gradient everywhere stroke-color-fn is in use
        let s = if "stroke-color-fn" in elem {
          gradient.linear(
            ..(sub-pts.at(0), sub-pts.at(1)).map(p => stroke-to-paint(
              (elem.stroke-color-fn)(..p),
            )),
          )
        } else { elem.stroke }
        place(line(
          // stroke: apply-color-fn(sub-pts.at(0), ..stroke-param),
          stroke: s,
          start: (ctx.on-canvas)(sub-pts.at(0)),
          end: (ctx.on-canvas)(sub-pts.at(1)),
        ))
      }
    }
    // huh, wait, what is this doing here
    // TODO: shouldn't this be in the outer scope
    render-marks(ctx, elem)
  }
}

/// Renders a @vertices, @polygon, @planeplot, @planeparam or @distribution
/// element: draws the (clipped) polygons, applying the color functions, and
/// the marks.
///
/// -> content
#let render-clipped-plane(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Element with evaluated `eval-points`
  /// -> dictionary
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
  render-marks(ctx,elem)
}

/// Renders a @plane element: draws the (clipped) polygon of the plane
///
/// -> content
#let render-plane(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Plane element with evaluated `eval-points`
  /// -> dictionary
  elem,
) = {
  let pts = elem.eval-points.at(0)
  if pts.len() > 2 {
    place(polygon(
      fill: elem.fill,
      stroke: elem.stroke,
      ..connect-circle-2d(..pts.map(ctx.on-canvas)),
    ))
  }
}

/// Renders a @vec element: draws the line and the tip/toe marks
///
/// -> content
#let render-vec(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Vec element with evaluated `eval-points`
  /// -> dictionary
  elem,
) = {
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

/// Renders the tick marks and labels of an axis
///
/// -> content
#let render-ticks(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Ticks as evaluated by @eval-ticks, a list of (label, tick, stroke)
  /// -> array
  ticks,
) = {
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

/// Renders an @axisline element: draws the line, the tip/toe marks, the
/// label and the ticks
///
/// -> content
#let render-axisline(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axisline element with evaluated `eval-points`
  /// -> dictionary
  elem,
) = {
  let (on-canvas, ..x) = ctx
  let (start, end) = elem.eval-points

  place(line(start: on-canvas(start), end: on-canvas(end), stroke: elem.stroke))

  // TODO: switch to eval-marks
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

/// Renders an @axisplane element: draws the plane polygon and the tick
/// grid
///
/// -> content
#let render-axisplane(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axisplane element with evaluated `eval-points`
  /// -> dictionary
  elem,
) = {
  let (on-canvas, ..x) = ctx
  place(polygon(
    fill: elem.fill,
    stroke: elem.stroke,
    ..elem.eval-points.map(on-canvas),
  ))
  render-ticks(ctx, elem.eval-ticks)
}

/// Renders an axis and all of its instances (@axisline and @axisplane)
///
/// -> content
#let render-axes(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axis element with evaluated instances
  /// -> dictionary
  axis,
) = {
  for i in axis.instances {
    if i.type == "axisline" {
      render-axisline(ctx, i)
    } else {
      render-axisplane(ctx, i)
    }
  }
}

/// Dictionary of all element render functions, keyed by element type. This
/// is used by @diagram to render the evaluated elements.
///
/// -> dictionary
#let render = (
  "axis": render-axes,
  "axisline": render-axisline,
  "axisplane": render-axisplane,
  "plane": render-plane,
  "vec": render-vec,
  "vertices": render-clipped-plane,
  "polygon": render-clipped-plane,
  "planeplot": render-clipped-plane,
  "planeparam": render-clipped-plane,
  "distribution": render-clipped-plane,
  "quiver": render-clipped-line,
  "lineplot": render-clipped-line,
  // "lineparam": render-clipped-line,
  "line": render-clipped-line,
  "path": render-clipped-line,
  "scatter": render-marks,
)

/// Renders a single legend entry: a small preview of the element (line or
/// area) together with its label
///
/// -> content
#let render-legend-label(
  /// Evaluated element
  /// -> dictionary
  elem,
  /// (width, format, dir, spacing) of the legend label as returned by
  /// @legend-label
  /// -> array
  (width, format, dir, spacing),
) = {
  let stroke = elem.stroke
  let fill = none
  let height = measure(format(elem.label, black, black)).height
  let image = if (
    elem.type
      in (
        "polygon",
        "plane",
        "planeplot",
        "vertices",
        "planeparam",
        "distribution",
      )
  ) {
    fill = elem.fill
    if (
      "stroke-color-fn" in elem and type(elem.stroke-color-fn) == function
        or "fill-color-fn" in elem and type(elem.stroke-color-fn) == function
    ) {
      let pts = elem.eval-points.join()
      let (min, max) = pts.fold((pts.at(0), pts.at(0)), minmax-vec)
      if "stroke-color-fn" in elem {
        // TODO: extrapolate
        stroke = gradient.linear(
          stroke-to-paint((elem.stroke-color-fn)(..min)),
          stroke-to-paint((elem.stroke-color-fn)(..max)),
        )
      }
      if "fill-color-fn" in elem {
        // TODO: extrapolate
        fill = gradient.linear(
          stroke-to-paint((elem.fill-color-fn)(..min)),
          stroke-to-paint((elem.fill-color-fn)(..max)),
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
        // "lineparam",
        "lineplot",
        "quiver",
      )
  ) {
    let stroke = elem.stroke
    if "stroke-color-fn" in elem and type(elem.stroke-color-fn) == function {
      let pts = elem.eval-points.join()
      let (min, max) = pts.fold((pts.at(0), pts.at(0)), minmax-vec)
      // TODO: extrapolate
      stroke = gradient.linear(
        stroke-to-paint((elem.stroke-color-fn)(..min)),
        stroke-to-paint((elem.stroke-color-fn)(..max)),
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

/// Renders the legend of a @diagram: a box containing a legend entry for
/// every labeled element
///
/// -> content
#let render-legend(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Legend parameters as returned by @legend-def
  /// -> dictionary
  legend-params,
  /// Evaluated elements to include in the legend
  /// -> array
  legend-elems,
  /// Width of the legend box
  /// -> auto | length | ratio
  width: auto,
  /// Height of the legend box
  /// -> auto | length | ratio
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
