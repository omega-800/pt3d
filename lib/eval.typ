#import "linalg.typ": *
#import "axes.typ": *
#import "clip.typ": *

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
  // FIXME:
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
  elem
}

#let eval-path(ctx, elem) = {
  elem.eval-points = clip-line(ctx, elem.path)
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
  elem
}

// TODO: axis only needed for ticks, remove eventually
#let eval-axis(ctx, axis, elem) = {
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
  if elem.type == "axisline" {
    let line-from = point-n(elem.position, min)
    let line-to = point-n(elem.position, max)
    elem.eval-points = (line-from, line-to)

    if elem.label != none {
      let from-3d = mid-vec(line-from, line-to)
      // FIXME: depends on tick label & offset
      let loff = 1em.to-absolute().pt() * 3.5pt

      let (label-x, label-y) = axis-tick-pos(
        ctx,
        elem.kind,
        elem.position,
        mid-vec(line-from, line-to),
        loff,
        elem.label,
      )
      // TODO: 3d points instead of 2d
      elem.eval-label = (label: elem.label, position: (label-x, label-y))
    }
    // TODO:
    if elem.format-ticks != none {
      let (length, offset) = elem.format-ticks
      let from = ((length / 2) + offset) / 1pt
      let to = ((length / 2) - offset) / 1pt
      let line-from = point-n(elem.position, min)
      let line-to = point-n(elem.position, max)
      elem.eval-ticks = ()
      for tick in axis.ticks {
        let loff = 1em.to-absolute().pt() * 1pt
        let label = (elem.format-ticks.label-format)(tick)
        let (start, end, label-x, label-y) = axis-tick-pos(
          ctx,
          elem.kind,
          elem.position,
          point-r(line-from, tick),
          loff,
          label,
          from-off: from,
          to-off: to,
        )
        // TODO: 3d points instead of 2d
        // TODO: apply format-ticks only on render
        elem.eval-ticks.push((
          label: (label: label, position: (label-x, label-y)),
          line: (start, end),
        ))
      }
    }
  } else {
    elem.eval-points = axis-plane-points(ctx, elem)
    if elem.format-ticks != none {
      elem.eval-ticks = ()
      let new-tick = (l, pos) => (
        label: if elem.format-ticks.label-format == none { none } else {
          // TODO: apply format-ticks only on render
          // TODO: position
          (label: (elem.format-ticks.label-format)(l), position: (0, 0, 0))
        },
        line: pos,
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
    if elem.label != none {
      elem.eval-label = (label: elem.label, position: (0pt, 0pt))
    }
  }
  elem
}

#let eval-axes(ctx, elem) = {
  elem.instances = elem.instances.map(i => eval-axis(ctx, elem, i))
  elem
}

#let eval-axis-points(ctx, elem) = {
  let (dim, ..x) = ctx
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

  let res = ()

  if (
    not elem.line.hidden
      and type(min) == int
      and type(max) == int
      and type(elem.line.position) == array
      and elem.line.position.len() == 2
      and elem.line.position.all(i => type(i) == int)
  ) {
    res.push(point-n(elem.line.position, min))
    res.push(point-n(elem.line.position, max))
  }
  if (
    not elem.plane.hidden
      and plane-points.all(pp => pp.all(i => type(i) == int))
  ) {
    for p in plane-points {
      res.push(p)
    }
  }

  res
}

// FIXME: this made compiling *VERY* slow for some reason?
#let eval-elem = (
  // TODO: eval-axis
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
    ..xaxis.instances,
    ..yaxis.instances,
    ..zaxis.instances,
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
