#import "linalg.typ": *
#import "axes.typ": *
#import "clip.typ": *
#import "mark.typ": *

#let eval-mark(elem, mark, from, to) = {
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

#let eval-marks(elem, mark, points) = {
  // TODO: first point
  points
    .map(pts => pts
      .windows(2)
      .map(((from, to)) => eval-mark(elem, mark, from, to)))
    .join()
}

#let plane-points-to-vertices(ctx, points) = {
  let vertices = ()
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  for (i, f) in points.slice(0, points.len() - 1).enumerate() {
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

#let eval-planeparam(ctx, elem) = {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
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

#let eval-lineparam(ctx, elem) = {
  let steps = if elem.steps == auto { 5 } else { elem.steps }
  elem.eval-points = clip-line(
    ctx,
    n-points-on-cube(ctx.dim, steps).map(p => (elem.lineparam)(
      ..p,
    )),
  )
  elem.eval-marks = eval-marks(elem, elem.mark, elem.eval-points)
  elem
}

#let eval-line(ctx, elem) = {
  elem.eval-points = (intersections-line-dim(elem.line, ctx.dim),)
  elem
}

#let eval-planeplot(ctx, elem) = {
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

#let eval-lineplot(ctx, elem) = {
  let (x, y, z) = elem.lineplot
  elem.eval-points = clip-line(ctx, x.zip(y, z))
  elem.eval-marks = eval-marks(elem, elem.mark, elem.eval-points)
  elem
}

#let eval-path(ctx, elem) = {
  elem.eval-points = clip-line(ctx, elem.path)
  elem.eval-marks = eval-marks(elem, elem.mark, elem.eval-points)
  elem
}

#let eval-vertices(ctx, elem) = {
  elem.eval-points = clip-vertices(ctx, elem.vertices)
  elem
}

#let eval-polygon(ctx, elem) = {
  elem.eval-points = (clip-plane(ctx, elem.polygon),)
  elem
}

#let eval-plane((dim, ..x), elem) = {
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
      points.push(sum-vec(a, a-b.map(i => i * t)))
    }
  }
  elem.eval-points = (points,)
  elem
}

#let eval-vec(ctx, elem) = {
  elem.eval-points = clip-line(ctx, elem.vec)
  elem.eval-tip = eval-mark(elem, elem.tip, ..elem.eval-points.at(0))
  elem.eval-toe = eval-mark(elem, elem.toe, ..elem.eval-points.at(0).rev())
  elem
}

#let eval-axisplane(ctx, elem) = {
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

  elem.eval-points = axis-plane-points(ctx, elem)
  elem.eval-ticks = ()
  if elem.format-ticks != none {
    let new-tick = (l, pos) => (
      label: if elem.format-ticks.label-format == none { none } else {
        // TODO: position
        (
          label: (elem.format-ticks.label-format)(l),
          position: (0, 0, 0),
          max: (0, 0, 0),
        )
      },
      tick: pos,
      stroke: if elem.format-ticks.stroke == auto { elem.stroke } else {
        elem.format-ticks.stroke
      },
    )

    let axis-ticks = a => {
      let axis = a
        .instances
        .filter(
          i => (
            i.format-ticks != none
          ),
        )
        .at(0, default: none)
      if axis == none or a.ticks == none { return () }
      let (kind, ticks, nticks) = a
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
    let (xas, yas, zas) = ctx.axes
    let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim

    // TODO: better auto ticks
    let xticks = axis-ticks(xas)
    let yticks = axis-ticks(yas)
    let zticks = axis-ticks(zas)

    // TODO: length, offset
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
  // TODO:
  elem.eval-label = if elem.label == none { none } else {
    // let line-from = point-n((min, min), elem.position)
    // let (start, end, label-pos, label-max) = axis-tick-pos(
    //   ctx,
    //   elem.kind,
    //   (min, min),
    //   line-from,
    //   1pt,
    //   elem.label,
    //   from-off: 5,
    //   to-off: 5,
    // )
    (label: elem.label, position: (0, 0, 0), max: (0, 0, 0))
  }
  elem
}

#let eval-axisline(ctx, elem) = {
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
    let (length, offset) = elem.format-ticks
    let from = ((length / 2) + offset) / 1pt
    let to = ((length / 2) - offset) / 1pt
    let line-from = point-n(elem.position, min)
    let line-to = point-n(elem.position, max)
    // TODO: separate labels and ticks
    for tick in elem.ticks {
      let loff = 1em.to-absolute().pt() * 1pt
      let label = if elem.format-ticks.label-format == none { none } else {
        (elem.format-ticks.label-format)(tick)
      }
      let (start, end, label-pos, label-max) = axis-tick-pos(
        ctx,
        elem.kind,
        elem.position,
        point-r(line-from, tick),
        loff,
        label,
        from-off: from,
        to-off: to,
      )
      elem.eval-ticks.push((
        label: if label == none { none } else {
          (label: label, position: label-pos, max: label-max)
        },
        tick: (start, end),
        stroke: if elem.format-ticks.stroke == auto { elem.stroke } else {
          elem.format-ticks.stroke
        },
      ))
    }
  }
  elem.eval-label = if (
    elem.label == none
      // FIXME: hacky
      or not ("on-canvas", "canvas-dim", "map-point-pt").all(c => c in ctx)
  ) { none } else {
    let mid-tick = if elem.eval-ticks.len() > 0 {
      elem.eval-ticks.at(int(elem.eval-ticks.len() / 2))
    } else { none }
    // FIXME: do this properly
    let (width, height) = measure(elem.label)
    let loff = if mid-tick == none {
      // FIXME: scuffed approximation
      (width + height) / 1.5
    } else if mid-tick.label == none {
      (
        // FIXME: scuffed approximation
        (elem.format-ticks.length + elem.format-ticks.offset)
          + (width + height) / 1.5
      )
    } else {
      let sub-lbl = measure(mid-tick.label.label)
      (
        // FIXME: scuffed approximation
        (elem.format-ticks.length + elem.format-ticks.offset)
          + (width + height + sub-lbl.width + sub-lbl.height)
      )
    }
    let (label-pos, label-max) = axis-tick-pos(
      ctx,
      elem.kind,
      elem.position,
      mid-vec(line-from, line-to),
      loff,
      elem.label,
    )
    (label: elem.label, position: label-pos, max: label-max)
  }
  elem.eval-tip = eval-mark(elem, elem.tip, ..elem.eval-points)
  elem.eval-toe = eval-mark(elem, elem.toe, ..elem.eval-points.rev())
  elem
}

#let eval-axes(ctx, elem) = {
  elem.instances = elem.instances.map(i => {
    if i.type == "axisline" {
      eval-axisline(ctx, i)
    } else {
      eval-axisplane(ctx, i)
    }
  })
  elem
}

#let eval-axisline-points(ctx, elem) = {
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

#let eval-axisplane-points(ctx, elem) = {
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
    if elem-eval.eval-label != none {
      res.push(elem-eval.eval-label.max)
    }
  }
  res
}

#let eval-axis-points(ctx, elem) = {
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
  "lineparam": eval-lineparam,
)

#let eval-points = (
  ctx,
  elem,
) => {
  if elem.type == "axis" {
    eval-axis-points(ctx, elem)
  } else if elem.type == "axisplane" {
    eval-axisline-points(ctx, elem)
  } else if elem.type == "axisline" {
    eval-axisplane-points(ctx, elem)
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
  } else {
    ()
  }
}

#let eval-min-bounds = (axes, ..children) => {
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

  points.fold(
    (
      points.at(0, default: (-10, -10, -10)),
      points.at(0, default: (10, 10, 10)),
    ),
    minmax-vec,
  )
}
