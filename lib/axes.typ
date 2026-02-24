#import "linalg.typ": *
#import "util.typ": *

#let axis-plane-points = (ctx, elem) => {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  if elem.kind == "x" {
    (
      (elem.position, ymin, zmin),
      (elem.position, ymax, zmin),
      (elem.position, ymax, zmax),
      (elem.position, ymin, zmax),
    )
  } else if elem.kind == "y" {
    (
      (xmin, elem.position, zmin),
      (xmax, elem.position, zmin),
      (xmax, elem.position, zmax),
      (xmin, elem.position, zmax),
    )
  } else {
    (
      (xmin, ymin, elem.position),
      (xmax, ymin, elem.position),
      (xmax, ymax, elem.position),
      (xmin, ymax, elem.position),
    )
  }
}

#let axis-helper-fn = (ctx, elem) => {
  let (dim, ..x) = ctx
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim

  if elem.kind == "x" {
    (
      point: x => (x, 0, 0),
      point-p: ((x, y, z), n) => (x, y + n, z + n),
      point-r: ((x, y, z), n) => (n, y, z),
      point-n: ((y, z), n) => (n, y, z),
      cur: ((x, y, z)) => x,
      min: xmin,
      max: xmax,
    )
  } else if elem.kind == "y" {
    (
      point: y => (0, y, 0),
      point-p: ((x, y, z), n) => (x + n, y, z + n),
      point-r: ((x, y, z), n) => (x, n, z),
      point-n: ((x, z), n) => (x, n, z),
      cur: ((x, y, z)) => y,
      min: ymin,
      max: ymax,
    )
  } else {
    (
      point: z => (0, 0, z),
      point-p: ((x, y, z), n) => (x + n, y + n, z),
      point-r: ((x, y, z), n) => (x, y, n),
      point-n: ((x, y), n) => (x, y, n),
      cur: ((x, y, z)) => z,
      min: zmin,
      max: zmax,
    )
  }
}

#let axis-tick-pos = (
  (dim, on-canvas, canvas-dim, map-point-pt),
  kind,
  position,
  from-3d,
  label-off,
  label,
  from-off: 0,
  to-off: 0,
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
  let (from, to) = (from-3d, to-3d).map(on-canvas).map(map-point-pt)

  let (from-scaled, to-scaled) = rescale-line(
    from,
    to,
    to-off,
    from-off: from-off,
  )

  let (from-3d-scaled, to-3d-scaled) = apply-2d-scale-to-3d(
    (from-3d, to-3d),
    (from, to),
    (from-scaled, to-scaled),
  )
  // let (from-3d-scaled, to-3d-scaled) = rescale-line(
  //   ..rescale-line(
  //     to-3d,
  //     from-3d,
  //     (d-end / d-orig) * d-3d,
  //     from-off: -(d-start / d-orig) * d-3d,
  //   ),
  //   0.5,
  //   from-off: -1,
  // )

  let (start-pt, end-pt) = (from-3d-scaled, to-3d-scaled)
    .map(on-canvas)
    .map(map-point-pt)
  let (start, end) = (start-pt, end-pt).map(v => v.map(i => i * 1pt))

  let (label-pos, label-max) = if label == none { (none, none) } else {
    let (width, height) = measure(label)

    // FIXME: do this properly
    let to-add = (width, height).map(i => i / 1pt).sum() + 5

    let (label-from, label-to) = rescale-line(
      start-pt,
      to,
      0,
      from-off: label-off / 1pt,
    )
    let (dx, dy) = label-from.map(i => i * 1pt)
    let (label-from-3d, _) = apply-2d-scale-to-3d(
      (from-3d-scaled, to-3d),
      (start-pt, to),
      (label-from, label-to),
    )
    let (label-max-3d, _) = apply-2d-scale-to-3d(
      (from-3d-scaled, to-3d),
      (start-pt, to),
      rescale-line(
        start-pt,
        to,
        0,
        from-off: label-off / 1pt + to-add,
      ),
    )

    let (dx, dy) = map-point-pt(on-canvas(label-from-3d)).map(i => i * 1pt)
    (label-from-3d, label-max-3d)
  }
  (
    start: from-3d-scaled,
    end: to-3d-scaled,
    label-pos: label-pos,
    label-max: label-max,
  )
}

#let axis-instance-defaults = (
  i,
  ctx,
) => {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  let (min, max, point-n) = axis-helper-fn(ctx, i)

  if i.type == "axisplane" {
    if i.position == auto {
      i.position = if i.kind == "z" { min } else { max }
    }
    if i.label == auto {
      i.label = none
    }
  }
  if i.type == "axisline" {
    if i.position.any(p => p == auto) {
      let def = (defmin, defmax) => {
        let (min, max) = i.position
        (
          if min == auto { defmin } else { min },
          if max == auto { defmax } else { max },
        )
      }
      i.position = if i.kind == "x" {
        def(ymin, zmin)
      } else if i.kind == "y" {
        def(xmin, zmin)
      } else {
        def(xmin, ymax)
      }
    }
    if i.label == auto {
      i.label = i.kind
    }
  }

  if i.format-ticks != none {
    if i.format-ticks.length == auto {
      i.format-ticks.length = 10pt
    }
    if i.format-ticks.offset == auto {
      i.format-ticks.offset = i.format-ticks.length / 2
    }
  }
  i
}

#let axis-ticks-default = (ctx, axis) => {
  let (on-canvas, dim, map-point-pt) = ctx
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let (min, max, point-n) = axis-helper-fn(ctx, (
    kind: axis.kind,
    type: "axisline",
  ))

  if type(axis.ticks) == array {
    return axis.ticks.filter(t => t <= max and t >= min)
  }
  let tick-l-ratios = axis
    .instances
    .filter(i => i.format-ticks != none and i.format-ticks.label-format != none)
    .map(i => {
      // TODO: calculate this properly
      let tick-l-size = measure((i.format-ticks.label-format)(-10.2))

      let (start, end) = (
        if i.type == "axisline" {
          (
            point-n(i.position, min),
            point-n(i.position, max),
          )
        } else {
          // TODO: FIXME: TODO: FIXME
          ((i.position, min, min), (i.position, max, max))
        }
      )
        .map(
          on-canvas,
        )
        .map(map-point-pt)
      let axis-size = distance-vec(start, end)
      int(calc.min(
        axis-size / tick-l-size.width.pt(),
        axis-size / tick-l-size.height.pt(),
      ))
    })
  let tick-l-ratio = if tick-l-ratios.len() > 0 {
    calc.max(..tick-l-ratios)
  } else { none }
  let n = if axis.nticks == auto and tick-l-ratio == none {
    10
  } else if axis.nticks == auto { tick-l-ratio } else { axis.nticks }
  n-points-on(min, max, if n == 0 { 10 } else { n })
}

#let axes-defaults = (xaxis, yaxis, zaxis, ctx) => (
  (xaxis, yaxis, zaxis)
    .zip(ctx.dim)
    .map(((axis, lim)) => {
      let a = (
        ..axis,
        lim: lim,
        instances: axis.instances.map(i => axis-instance-defaults(
          i,
          ctx,
        )),
      )
      a.ticks = axis-ticks-default(ctx, a)
      // FIXME: wonky
      a.instances = a.instances.map(i => if i.format-ticks != none {
        (..i, ticks: a.ticks)
      } else { i })
      a
    })
)
