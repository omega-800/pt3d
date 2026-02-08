#import "linalg.typ": *
#import "util.typ": *

#let axis-helper-fn = (ctx, elem) => {
  let (dim, ..x) = ctx
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim

  if elem.kind == "x" {
    let pp = if "plane" in elem {
      (
        (elem.plane.position, ymin, zmin),
        (elem.plane.position, ymax, zmin),
        (elem.plane.position, ymax, zmax),
        (elem.plane.position, ymin, zmax),
      )
    } else { () }
    (
      point: x => (x, 0, 0),
      point-p: ((x, y, z), n) => (x, y + n, z + n),
      point-r: ((x, y, z), n) => (n, y, z),
      point-n: ((y, z), n) => (n, y, z),
      cur: ((x, y, z)) => x,
      min: xmin,
      max: xmax,
      plane-points: pp,
    )
  } else if elem.kind == "y" {
    let pp = if "plane" in elem {
      (
        (xmin, elem.plane.position, zmin),
        (xmax, elem.plane.position, zmin),
        (xmax, elem.plane.position, zmax),
        (xmin, elem.plane.position, zmax),
      )
    }
    (
      point: y => (0, y, 0),
      point-p: ((x, y, z), n) => (x + n, y, z + n),
      point-r: ((x, y, z), n) => (x, n, z),
      point-n: ((x, z), n) => (x, n, z),
      cur: ((x, y, z)) => y,
      min: ymin,
      max: ymax,
      plane-points: pp,
    )
  } else {
    let pp = if "plane" in elem {
      (
        (xmin, ymin, elem.plane.position),
        (xmax, ymin, elem.plane.position),
        (xmax, ymax, elem.plane.position),
        (xmin, ymax, elem.plane.position),
      )
    }
    (
      point: z => (0, 0, z),
      point-p: ((x, y, z), n) => (x + n, y + n, z),
      point-r: ((x, y, z), n) => (x, y, n),
      point-n: ((x, y), n) => (x, y, n),
      cur: ((x, y, z)) => z,
      min: zmin,
      max: zmax,
      plane-points: pp,
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

// TODO:
#let axis-instance-defaults = (
  i,
  ctx,
) => {
  let (dim, canvas-dim, on-canvas, map-point-pt) = ctx
  let (width, height) = canvas-dim
  let ((xmin, xmax), (ymin, ymax), (zmin, zmax)) = dim
  let (min, max, point-n) = axis-helper-fn(ctx, i)

  if i.plane.position == auto {
    i.plane.position = if i.kind == "z" { min } else { max }
  }
  if i.line.position.any(p => p == auto) {
    let def = (defmin, defmax) => {
      let (min, max) = i.line.position
      (
        if min == auto { defmin } else { min },
        if max == auto { defmax } else { max },
      )
    }
    i.line.position = if i.kind == "x" {
      def(ymin, zmin)
    } else if i.kind == "y" {
      def(xmin, zmin)
    } else {
      def(xmin, ymax)
    }
  }

  let tick-l-ratio = none
  if i.format-ticks != none {
    if i.format-ticks.length == auto {
      i.format-ticks.length = 10pt
    }
    if i.format-ticks.offset == auto {
      i.format-ticks.offset = i.format-ticks.length / 2
    }
    if i.format-ticks.label-format != none {
      // TODO: calculate this properly
      let tick-l-size = measure((i.format-ticks.label-format)(-10.2))
      let (start, end) = (
        point-n(i.line.position, min),
        point-n(i.line.position, max),
      )
        .map(
          on-canvas,
        )
        .map(map-point-pt)
      let axis-size = length-vec(direction-vec(end, start))
      tick-l-ratio = int(calc.min(
        axis-size / tick-l-size.width.pt(),
        axis-size / tick-l-size.height.pt(),
      ))
    }
  }
  i.ticks = if type(i.ticks) == array {
    i.ticks.filter(t => t <= max and t >= min)
  } else {
    let n = if i.nticks == auto and tick-l-ratio == none {
      10
    } else if i.nticks == auto { tick-l-ratio } else { i.nticks }
    n-points-on(min, max, if n == 0 { 10 } else { n })
  }
  i
}

#let axes-defaults = (xaxis, yaxis, zaxis, ctx) => {
  let (xlim, ylim, zlim) = ctx.dim
  let xas = (
    ..xaxis,
    lim: xlim,
    instances: xaxis.instances.map(i => axis-instance-defaults(
      i,
      ctx,
    )),
  )
  let yas = (
    ..yaxis,
    lim: ylim,
    instances: yaxis.instances.map(i => axis-instance-defaults(
      i,
      ctx,
    )),
  )
  let zas = (
    ..zaxis,
    lim: zlim,
    instances: zaxis.instances.map(i => axis-instance-defaults(
      i,
      ctx,
    )),
  )

  (xas, yas, zas)
}
