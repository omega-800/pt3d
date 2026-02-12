#import "linalg.typ": *
#import "util.typ": *

#let axis-kind-case = (kind, (x, y, z)) => if kind == "x" { x } else if (
  kind == "y"
) { y } else { z }

#let axis-plane-points = (ctx, elem) => {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  axis-kind-case(elem.kind, (
    (
      (elem.position, ymin, zmin),
      (elem.position, ymax, zmin),
      (elem.position, ymax, zmax),
      (elem.position, ymin, zmax),
    ),
    (
      (xmin, elem.position, zmin),
      (xmax, elem.position, zmin),
      (xmax, elem.position, zmax),
      (xmin, elem.position, zmax),
    ),
    (
      (xmin, ymin, elem.position),
      (xmax, ymin, elem.position),
      (xmax, ymax, elem.position),
      (xmin, ymax, elem.position),
    ),
  ))
}

#let axis-helper-fn = (ctx, elem) => {
  let (dim, ..x) = ctx
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  axis-kind-case(elem.kind, (
    (
      point: x => (x, 0, 0),
      point-p: ((x, y, z), n) => (x, y + n, z + n),
      point-r: ((x, y, z), n) => (n, y, z),
      point-n: ((y, z), n) => (n, y, z),
      cur: ((x, y, z)) => x,
      other: ((x, y, z)) => (y, z),
      min: xmin,
      max: xmax,
    ),
    (
      point: y => (0, y, 0),
      point-p: ((x, y, z), n) => (x + n, y, z + n),
      point-r: ((x, y, z), n) => (x, n, z),
      point-n: ((x, z), n) => (x, n, z),
      cur: ((x, y, z)) => y,
      other: ((x, y, z)) => (x, z),
      min: ymin,
      max: ymax,
    ),
    (
      point: z => (0, 0, z),
      point-p: ((x, y, z), n) => (x + n, y + n, z),
      point-r: ((x, y, z), n) => (x, y, n),
      point-n: ((x, y), n) => (x, y, n),
      cur: ((x, y, z)) => z,
      other: ((x, y, z)) => (x, y),
      min: zmin,
      max: zmax,
    ),
  ))
}

#let label-left = (ctx, kind, position) => {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = ctx.dim
  let relto = (min, max) => v => (v - min) / (max - min) * 100
  let reltox = relto(xmin, xmax)
  let reltoy = relto(ymin, ymax)
  let reltoz = relto(zmin, zmax)
  let (pos1, pos2) = position
  axis-kind-case(kind, (
    (
      (
        reltoy(pos1) > 50 and reltoy(pos1) >= 100 - reltoz(pos2)
      )
        or (
          reltoz(pos2) > 50 and 100 - reltoy(pos1) <= reltoz(pos2)
        )
    ),
    (
      (
        reltox(pos1) < 50 and reltox(pos1) <= 100 - reltoz(pos2)
      )
        or (
          reltoz(pos2) < 50 and reltox(pos1) <= 100 - reltoz(pos2)
        )
    ),
    (
      (
        reltox(pos1) < 50 and reltox(pos1) <= reltoy(pos2)
      )
        or (
          reltoy(pos2) > 50 and reltox(pos1) <= reltoy(pos2)
        )
    ),
  ))
}

#let axis-tick-pos = (
  (dim, on-canvas, canvas-dim, map-point-pt),
  kind,
  from-3d,
  // TODO: parametarizeable positions other than "left/right"
  label-left,
  label-off,
  label,
  from-off: 0,
  to-off: 0,
) => {
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim

  let (px, py, pz) = from-3d
  let to-3d = if label-left {
    axis-kind-case(kind, (
      (px, py - 1, pz),
      (px + 1, py, pz),
      (px, py - 1, pz),
    ))
  } else {
    axis-kind-case(kind, (
      (px, py + 1, pz),
      (px, py, pz - 1),
      (px, py + 1, pz),
    ))
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
    if i.format-ticks != none {
      i.format-ticks = i.format-ticks.map(f => {
        // TODO: len
        // TODO: dir (label-left)
        let l = if f.length == auto { 20pt } else { f.length }
        (
          ..f,
          length: l,
          offset: if f.offset == auto { l / 2 } else { f.offset },
          dir: if f.dir == auto { "x" } else { f.dir },
        )
      })
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
      i.position = axis-kind-case(i.kind, (
        def(ymin, zmin),
        def(xmin, zmin),
        def(xmin, ymax),
      ))
    }
    if i.label == auto {
      i.label = i.kind
    }
    if i.format-ticks != none {
      if i.format-ticks.length == auto {
        i.format-ticks.length = 10pt
      }
      if i.format-ticks.offset == auto {
        i.format-ticks.offset = i.format-ticks.length / 2
      }
      // TODO: dir (label-left)
      if i.format-ticks.dir == auto {
        i.format-ticks.dir = axis-kind-case(i.kind, ("y", "x", "y"))
      }
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
    .filter(i => (
      i.format-ticks != none
        and (
          (
            type(i.format-ticks) == dictionary
              and i.format-ticks.label-format != none
          )
            or (
              type(i.format-ticks) == list
                and i.format-ticks.any(f => f.label-format != none)
            )
        )
    ))
    .map(i => {
      let fmt = if type(i.format-ticks) == list { i.format-ticks } else {
        (i.format-ticks,)
      }
      // TODO: calculate this properly
      let tick-l-size = calc.max(
        ..fmt
          .filter(f => f.label-format != none)
          .map(f => measure((f.label-format)(
            -10.2,
          ))),
      )

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
  (..n-points-on(min, max, if n == 0 { 9 } else { n - 1 }), max)
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
