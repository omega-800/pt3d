#import "linalg.typ": *
#import "axes.typ": *
#import "clip.typ": *
#import "mark.typ": *

/// Evaluates a single mark (e.g. a line endpoint, a quiver tip or a
/// distribution outlier) into a renderable mark element. If `mark` is a
/// string, it is looked up in @marks.
///
/// -> dictionary
#let eval-mark(
  /// Element the mark belongs to
  /// -> dictionary
  elem,
  /// Mark name, string or function
  /// -> none | str | function
  mark,
  /// Start of the line segment
  /// -> vector
  from,
  /// End of the line segment
  /// -> vector
  to,
) = {
  if mark == none or (type(mark) != str and type(mark) != function) {
    return mark
  }
  let markfn = if type(mark) != str {
    mark
  } else if mark in marks {
    marks.at(mark)
  } else {
    text-mark.with(body: mark)
  }

  let mstroke = if (
    "stroke-color-fn" in elem and type(elem.stroke-color-fn) == function
  ) {
    (elem.stroke-color-fn)(..to)
  } else { elem.stroke }
  let mfill = if (
    "fill-color-fn" in elem and type(elem.fill-color-fn) == function
  ) {
    (elem.fill-color-fn)(..to)
  } else if "fill" in elem {
    elem.fill
  } else {
    if type(mstroke) == stroke { mstroke.paint } else { mstroke }
  }

  let res = markfn((fill: mfill, stroke: mstroke, from: from, to: to))
  (mark: res, from: from, to: to)
}

/// Calculates the point at distance $d$ past `to` on the line through
/// `from` and `to`. Marks are anchored to this point so that they end
/// exactly on `to`.
///
/// -> array
#let get-0th-pt(
  /// Start of the line segment
  /// -> vector
  from,
  /// End of the line segment
  /// -> vector
  to,
) = {
  // TODO: probably correct? i don't have the time to check
  // FIXME: check if this still works
  let d = distance-vec(from, to)
  rescale-line(
    from,
    to,
    d,
    from-off: d,
  )
}

/// Evaluates all marks of a polyline (e.g. the intermediate points of a
/// @lineplot) into renderable mark elements.
///
/// -> array
#let eval-marks(
  /// Element the marks belong to
  /// -> dictionary
  elem,
  /// Mark name, string or function
  /// -> none | str | function
  mark,
  /// Polyline as a list of 3d points
  /// -> array
  points,
) = {
  points
    .filter(pts => pts.len() > 1)
    .map(pts => (get-0th-pt(pts.at(0), pts.at(1)).at(0), ..pts)
      .windows(2)
      .map(((from, to)) => eval-mark(elem, mark, from, to)))
    .join()
}

/// Converts a 2d grid of 3d points into a mesh of (clipped) triangles
///
/// -> array
#let plane-points-to-vertices(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// 2d grid of 3d points as $(x, y, z)$
  /// -> array
  points,
) = {
  // something smells very fishy in here
  // TODO: revisit clipping
  let vertices = ()
  for (i, f) in points.slice(0, points.len() - 1).enumerate() {
    // x-axis plane
    for (ii, ff) in f.slice(0, f.len() - 1).enumerate() {
      let p11 = ff
      let p12 = f.at(ii + 1)
      let p13 = points.at(i + 1).at(ii)

      let p21 = f.at(ii + 1)
      let p22 = points.at(i + 1).at(ii)
      let p23 = points.at(i + 1).at(ii + 1)

      for triangle in ((p11, p12, p13), (p21, p22, p23)) {
        let clipped = clip-plane(ctx, triangle)
        if clipped.len() > 0 {
          vertices.push(clipped)
        }
      }
    }
  }
  vertices
}

/// Evaluates a @planeparam element: samples the parametrized plane over the
/// bounding volume and stores the resulting surface in `eval-points`.
///
/// -> dictionary
#let eval-planeparam(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Planeparam element
  /// -> dictionary
  elem,
) = {
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  let p-x-y-z = x-y-points(ctx.dim, steps).map(ps => ps.map((
    (x, y),
  ) => (
    x,
    y,
    (elem.planeparam)(x, y),
  )))
  elem.eval-points = plane-points-to-vertices(ctx, p-x-y-z)
  elem
}

// #let eval-lineparam(ctx, elem) = {
//   let steps = if elem.steps == auto { 5 } else { elem.steps }
//   elem.eval-points = clip-line(
//     ctx,
//     n-points-on-cube(ctx.dim, steps).map(p => (elem.lineparam)(
//       ..p,
//     )),
//   )
//   elem.eval-marks = eval-marks(elem, elem.mark, elem.eval-points)
//   elem
// }

/// Evaluates a @line element: clips the line to the bounding volume and
/// stores the visible part in `eval-points`.
///
/// -> dictionary
#let eval-line(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Line element
  /// -> dictionary
  elem,
) = {
  elem.eval-points = (intersections-line-dim(elem.line, ctx.dim),)
  elem
}

/// Evaluates a @planeplot element: converts the sampled surface into a
/// (clipped) triangulation and stores it in `eval-points`.
///
/// -> dictionary
#let eval-planeplot(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Planeplot element
  /// -> dictionary
  elem,
) = {
  let (x, y, z, num) = elem.planeplot
  let pts = x.zip(y, z)
  elem.eval-points = if num != none {
    // TODO:
    plane-points-to-vertices(
      ctx,
      pts.chunks(num),
    )
  } else {
    // TODO:
    (clip-plane(ctx, pts),)
  }
  elem
}

/// Evaluates a @lineplot element: clips the polyline to the bounding volume
/// and stores the visible part in `eval-points`.
///
/// -> dictionary
#let eval-lineplot(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Lineplot element
  /// -> dictionary
  elem,
) = {
  let (x, y, z) = elem.lineplot
  elem.eval-points = clip-line(ctx, x.zip(y, z))
  elem.eval-marks = eval-marks(elem, elem.mark, elem.eval-points)
  elem
}

/// Evaluates a @path element: clips the polyline to the bounding volume and
/// stores the visible part in `eval-points`.
///
/// -> dictionary
#let eval-path(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Path element
  /// -> dictionary
  elem,
) = {
  elem.eval-points = clip-line(ctx, elem.path)
  elem.eval-marks = eval-marks(elem, elem.mark, elem.eval-points)
  elem
}

/// Evaluates a @vertices element: clips the polygons to the bounding volume
/// and stores the visible part in `eval-points`.
///
/// -> dictionary
#let eval-vertices(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Vertices element
  /// -> dictionary
  elem,
) = {
  elem.eval-points = clip-vertices(ctx, elem.vertices)
  elem
}

/// Evaluates a @polygon element: clips the polygon to the bounding volume
/// and stores the visible part in `eval-points`.
///
/// -> dictionary
#let eval-polygon(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Polygon element
  /// -> dictionary
  elem,
) = {
  elem.eval-points = (clip-plane(ctx, elem.polygon),)
  elem
}

/// Evaluates a @plane element: computes the intersection of the plane with
/// the bounding volume and stores the resulting polygon in `eval-points`.
///
/// -> dictionary
#let eval-plane(
  /// Canvas context
  /// -> dictionary
  (dim, ..x),
  /// Plane element
  /// -> dictionary
  elem,
) = {
  let (n, p) = elem.plane
  let points = ()
  for (a, b) in cube-edges(dim) {
    let a-b = direction-vec(a, b)
    let denom = dot-product(n, a-b)
    if denom == 0 {
      continue
    }
    let t = (
      dot-product(n.map(i => -i), direction-vec(p, a)) / denom
    )
    if t >= 0 and t <= 1 {
      points.push(sum-vec(a, scalar-mult-vec(t, a-b)))
    }
  }
  elem.eval-points = (points,)
  elem
}

/// Evaluates a @vec element: clips the vector line to the bounding volume
/// and evaluates its tip and toe marks.
///
/// -> dictionary
#let eval-vec(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Vec element
  /// -> dictionary
  elem,
) = {
  elem.eval-points = clip-line(ctx, elem.vec)
  if elem.eval-points.len() > 0 and elem.eval-points.at(0).len() > 1 {
    elem.eval-tip = eval-mark(elem, elem.tip, ..elem.eval-points.at(0))
    elem.eval-toe = eval-mark(elem, elem.toe, ..elem.eval-points.at(0).rev())
  } else {
    elem.eval-tip = none
    elem.eval-toe = none
  }
  elem
}

/// Evaluates a @distribution element: bins the sample points into a surface
/// and evaluates the outlier marks.
///
/// -> dictionary
#let eval-distribution(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Distribution element
  /// -> dictionary
  elem,
) = {
  // TODO: xlim, ylim proper
  let ((xmin, xmax), (ymin, ymax), (zmin, _)) = ctx.dim
  let (plane, points, ysteps) = dist3d(
    elem.xs,
    elem.ys,
    xn: elem.xn,
    yn: elem.yn,
    xlim: (
      or-default(xmin, calc.min(..elem.xs)),
      or-default(xmax, calc.max(..elem.xs)),
    ),
    ylim: (
      or-default(ymin, calc.min(..elem.ys)),
      or-default(ymax, calc.max(..elem.ys)),
    ),
  )
  let (x, y, z) = plane

  let pts = x.zip(y, z)
  elem.eval-points = plane-points-to-vertices(
    ctx,
    pts.chunks(ysteps.len()),
  )

  let ms = points.map(((x, y, z)) => (
    x,
    y,
    or-default(zmin, 0),
  ))

  elem.eval-marks = eval-marks(elem, elem.mark, (
    if "out-of-bounds" in ctx {
      ms.filter(p => not (ctx.out-of-bounds)(p))
    } else {
      ms
    },
  ))
  elem
}

/// Evaluates a @quiver element: computes the vector field lines from the
/// direction function and evaluates the tip and toe marks.
///
/// -> dictionary
#let eval-quiver(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Quiver element
  /// -> dictionary
  elem,
) = {
  // TODO:
  elem.eval-points = elem
    .xs
    .zip(elem.ys, elem.zs)
    .map(v => {
      let nv = sum-vec(v, (elem.dir)(..v))
      let d = distance-vec(v, nv)
      clip-line(ctx, (
        if d > 0 {
          // TODO: norm
          rescale-line(v, nv, elem.scale * if elem.norm { 1 } else { d })
          // (v,nv)
        } else {
          (v, nv)
        }
      )).at(0)
    })
    .filter(v => (
      v != none
        and not v.any(vv => vv == none)
        and v.len() > 1
        and distance-vec(v.at(0), v.at(1)) > 0
    ))
  // TODO: only eval if mark != none
  elem.eval-marks = (
    ..eval-marks(elem, elem.tip, elem.eval-points),
    ..eval-marks(elem, elem.toe, elem.eval-points.map(l => l.rev())),
  )
  elem
}

/// Evaluates the ticks of an axis line into renderable (label, tick,
/// stroke) tuples.
///
/// -> array
#let eval-ticks(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Tick positions
  /// -> array
  ticks,
  /// Tick format as returned by @tickformat
  /// -> dictionary
  format-ticks,
  /// Start of the axis line
  /// -> vector
  line-from,
  /// End of the axis line
  /// -> vector
  line-to,
  /// Axis kind, one of `x`, `y` and `z`
  /// -> str
  kind,
  /// Stroke of the axis
  /// -> auto | none | length | color | gradient | stroke | tiling | dictionary
  elem-stroke,
) = {
  let (point-r,) = axis-helper-fn(
    ctx,
    (kind: kind),
  )
  let res = ()
  // TODO: separate labels and ticks
  for tick in ticks {
    // TODO:
    let (start, end, label, label-pos, label-max) = axis-tick-pos(
      ctx,
      kind,
      point-r(line-from, tick),
      format-ticks,
      tick,
    )
    res.push((
      label: if label == none { none } else {
        (label: label, position: label-pos, max: label-max)
      },
      tick: (start, end),
      stroke: if format-ticks.stroke == auto { elem-stroke } else {
        format-ticks.stroke
      },
    ))
  }
  res
}

/// Evaluates an @axisplane element: computes the corners of the axis plane
/// and the grid lines of the ticks on it.
///
/// -> dictionary
#let eval-axisplane(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axisplane element
  /// -> dictionary
  elem,
) = {
  let (
    point,
    point-p,
    point-r,
    point-n,
    cur,
    other,
    min,
    max,
  ) = axis-helper-fn(
    ctx,
    elem,
  )

  elem.eval-points = axis-plane-points(ctx, elem)
  elem.eval-ticks = ()
  if elem.format-ticks != none {
    let new-tick = (l, pos) => (
      label: none,
      // label: if elem.format-ticks.label-format == none { none } else {
      //   // TODO: position
      //   (
      //     label: (elem.format-ticks.label-format)(l),
      //     position: (0, 0, 0),
      //     max: (0, 0, 0),
      //   )
      // },
      tick: pos,
      stroke: elem.stroke,
      // stroke: if elem.format-ticks.stroke == auto { elem.stroke } else {
      //   elem.format-ticks.stroke
      // },
    )

    let (xas, yas, zas) = ctx.axes
    let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim

    let xticks = xas.ticks
    let yticks = yas.ticks
    let zticks = zas.ticks
    let all-ticks = (
      "x": xticks,
      "y": yticks,
      "z": zticks,
    )

    let line-from = point-r((xmin, ymin, zmin), elem.position)
    let line-to = point-r((xmax, ymax, zmax), elem.position)
    let kinds = axis-kind-case(elem.kind, (
      ("y", "z"),
      ("x", "z"),
      ("x", "y"),
    ))
    // TODO: length, offset
    // for (i, kind) in kinds.enumerate() {
    //   for tick in eval-ticks(
    //     ctx,
    //     all-ticks.at(kind),
    //     elem.format-ticks.at(i),
    //     line-from,
    //     line-to,
    //     kind,
    //     elem.stroke,
    //   ) {
    //     elem.eval-ticks.push(tick)
    //   }
    // }

    // FIXME:
    if elem.kind == "z" {
      for tick in xticks {
        elem.eval-ticks.push(new-tick(tick, (
          (tick, ymin, elem.position),
          (tick, ymax, elem.position),
        )))
      }
      for tick in yticks {
        elem.eval-ticks.push(new-tick(tick, (
          (xmin, tick, elem.position),
          (xmax, tick, elem.position),
        )))
      }
    } else if elem.kind == "y" {
      for tick in xticks {
        elem.eval-ticks.push(new-tick(tick, (
          (tick, elem.position, zmin),
          (tick, elem.position, zmax),
        )))
      }
      for tick in zticks {
        elem.eval-ticks.push(new-tick(tick, (
          (xmin, elem.position, tick),
          (xmax, elem.position, tick),
        )))
      }
    } else {
      for tick in yticks {
        elem.eval-ticks.push(new-tick(tick, (
          (elem.position, tick, zmin),
          (elem.position, tick, zmax),
        )))
      }
      for tick in zticks {
        elem.eval-ticks.push(new-tick(tick, (
          (elem.position, ymin, tick),
          (elem.position, ymax, tick),
        )))
      }
    }
  }
  elem
}

/// Evaluates an @axisline element: computes the endpoints, ticks, label and
/// tip/toe marks of the axis line.
///
/// -> dictionary
#let eval-axisline(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axisline element
  /// -> dictionary
  elem,
) = {
  let (
    point,
    point-p,
    point-r,
    point-n,
    cur,
    min,
    max,
  ) = axis-helper-fn(
    ctx,
    elem,
  )
  let line-from = point-n(elem.position, min)
  let line-to = point-n(elem.position, max)
  elem.eval-points = (line-from, line-to)
  // TODO:
  elem.eval-ticks = ()
  if (
    elem.format-ticks != none
      // FIXME: hacky
      and elem.format-ticks.length != auto
      and elem.format-ticks.offset != auto
      and ("on-canvas", "canvas-dim", "map-point-pt").all(c => c in ctx)
  ) {
    elem.eval-ticks = eval-ticks(
      ctx,
      elem.ticks,
      elem.format-ticks,
      line-from,
      line-to,
      elem.kind,
      elem.stroke,
    )
  }
  elem.eval-label = if (
    elem.label == none
      // FIXME: hacky
      or not ("on-canvas", "canvas-dim", "map-point-pt").all(c => c in ctx)
  ) { none } else {
    let mid-tick = if elem.eval-ticks.len() > 0 {
      elem.eval-ticks.at(int(elem.eval-ticks.len() / 2))
    } else { none }
    // TODO:
    let (label-pos, label-max) = axis-tick-pos(
      ctx,
      elem.kind,
      mid-vec(line-from, line-to),
      (..elem.format-ticks, label-format: tick => tick),
      elem.label,
      label-off: 2em,
    )
    (label: elem.label, position: label-pos, max: label-max)
  }
  elem.eval-tip = eval-mark(elem, elem.tip, ..elem.eval-points)
  elem.eval-toe = eval-mark(elem, elem.toe, ..elem.eval-points.rev())
  elem
}

/// Evaluates an axis and all of its instances (@axisline and @axisplane)
///
/// -> dictionary
#let eval-axes(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axis element
  /// -> dictionary
  elem,
) = {
  elem.instances = elem.instances.map(i => {
    if i.type == "axisline" {
      eval-axisline(ctx, i)
    } else {
      eval-axisplane(ctx, i)
    }
  })
  elem
}

/// Collects all 3d points of an evaluated @axisline element (line, ticks
/// and label) for bounding box evaluation
///
/// -> array
#let eval-axisline-points(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axisline element
  /// -> dictionary
  elem,
) = {
  let res = ()
  let (min, max) = axis-helper-fn(ctx, elem)
  if (
    is-num(min)
      and is-num(max)
      and type(elem.position) == array
      and elem.position.len() == 2
      and elem.position.all(is-num)
  ) {
    let elem-eval = eval-axisline(ctx, elem)
    res = elem-eval.eval-points
    for (label, tick) in elem-eval.eval-ticks {
      let (start, end) = tick
      res.push(start)
      res.push(end)
      if label != none {
        res.push(label.max)
      }
    }
    if elem-eval.eval-label != none {
      res.push(elem-eval.eval-label.max)
    }
  }

  res
}

/// Collects all 3d points of an evaluated @axisplane element (corners and
/// tick lines) for bounding box evaluation
///
/// -> array
#let eval-axisplane-points(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axisplane element
  /// -> dictionary
  elem,
) = {
  let res = ()
  if (
    axis-plane-points(ctx, elem).all(pp => pp.all(is-num))
  ) {
    let elem-eval = eval-axisplane(ctx, elem)
    res = elem-eval.eval-points
    for (label, tick) in elem-eval.eval-ticks {
      let (start, end) = tick
      res.push(start)
      res.push(end)
      if label != none {
        res.push(label.max)
      }
    }
  }
  res
}

/// Collects all 3d points of an evaluated axis for bounding box evaluation
///
/// -> array
#let eval-axis-points(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Axis element
  /// -> dictionary
  elem,
) = {
  elem
    .instances
    .map(i => {
      if i.type == "axisline" {
        eval-axisline-points(ctx, i)
      } else {
        eval-axisplane-points(ctx, i)
      }
    })
    .join()
}

// TODO: eval marks
/// Dictionary of all element evaluators, keyed by element type. This is
/// used by @diagram to evaluate the elements.
///
/// -> dictionary
#let eval-elem = (
  "axis": eval-axes,
  "path": eval-path,
  "polygon": eval-polygon,
  "vertices": eval-vertices,
  "vec": eval-vec,
  "lineplot": eval-lineplot,
  "planeplot": eval-planeplot,
  "plane": eval-plane,
  "planeparam": eval-planeparam,
  "line": eval-line,
  "distribution": eval-distribution,
  "quiver": eval-quiver,
  // "lineparam": eval-lineparam,
)

/// Collects all 3d points of an element for bounding box evaluation. This is
/// used by @diagram to find the extents of the plot.
///
/// -> array
#let eval-points(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Element
  /// -> dictionary
  elem,
) = {
  if elem.type == "axis" {
    eval-axis-points(ctx, elem)
  } else if elem.type == "axisplane" {
    eval-axisplane-points(ctx, elem)
  } else if elem.type == "axisline" {
    eval-axisline-points(ctx, elem)
  } else if elem.type == "path" {
    elem.path
  } else if elem.type == "polygon" {
    elem.polygon
  } else if elem.type == "vertices" {
    elem.vertices.join()
  } else if elem.type == "vec" {
    elem.vec
  } else if elem.type == "lineplot" {
    let (x, y, z) = elem.lineplot
    x.zip(y, z)
  } else if elem.type == "planeplot" {
    let (x, y, z, _) = elem.planeplot
    x.zip(y, z)
  } else if elem.type == "quiver" {
    // TODO: distance
    elem.xs.zip(elem.ys, elem.zs)
  } else if elem.type == "distribution" {
    // TODO: distribution
    let elem = eval-distribution(ctx, elem)
    // TODO: marks
    elem.eval-points.join()
  } else {
    ()
  }
}

/// Calculates the (minimum, maximum) bounding box of all the elements and
/// axes of a plot. Used by @diagram to determine the bounding volume.
///
/// -> array
#let eval-min-bounds(
  /// The 3 axes
  /// -> array
  axes,
  /// The elements of the plot
  /// -> array
  ..children,
) = {
  let (xaxis, yaxis, zaxis) = axes

  let getlim = (lim: auto, ..x) => if type(lim) != array { (auto, auto) } else {
    lim
  }

  let xlim = getlim(..xaxis)
  let ylim = getlim(..yaxis)
  let zlim = getlim(..zaxis)
  let dim = (xlim, ylim, zlim)

  // TODO: only evaluate if necessary

  let ctx = (dim: dim, axes: axes)
  let points = (
    xaxis,
    yaxis,
    zaxis,
    ..children.pos(),
  )
    .map(elem => eval-points(ctx, elem))
    .fold((), (acc, cur) => (..acc, ..cur))

  let (min, max) = points.fold(
    (
      points.at(0, default: (-10, -10, -10)),
      points.at(0, default: (10, 10, 10)),
    ),
    minmax-vec,
  )

  (min.map(calc.floor), max.map(calc.ceil))
}


