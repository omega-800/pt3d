#import "util.typ": *
#import "eval.typ": *

#let ortho-proj = (((xmin, xmax), (ymin, ymax), _), (x, y, z)) => (
  (2 * x - xmax - xmin) / (xmax - xmin),
  (2 * y - ymax - ymin) / (ymax - ymin),
)

#let out-of-bounds-2d = x => x > 100% or x < 0%

#let clamp-to-bounds-3d = ((xmin, xmax), (ymin, ymax), (zmin, zmax)) => (
  (x, y, z),
) => (
  calc.clamp(x, xmin, xmax),
  calc.clamp(y, ymin, ymax),
  calc.clamp(z, zmin, zmax),
)

#let out-of-bounds-3d = ((xmin, xmax), (ymin, ymax), (zmin, zmax)) => (
  (x, y, z),
) => x < xmin or x > xmax or y < ymin or y > ymax or z < zmin or z > zmax

#let overflow-correction = ns => {
  let s = ns.filter(out-of-bounds-2d).sorted()
  let high = calc.max(s.last(default: 100%), 100%)
  let low = calc.min(s.first(default: 0%), 0%)
  let span = high - low
  (
    -low / span * 100%,
    (100% / span) * 100%,
  )
}

#let rescale = ((xo, xscale), (yo, yscale)) => (
  (x, y),
) => (x * xscale + xo, y * yscale + yo)

#let order-axes = ((xo, yo, zo)) => ((x, y, z)) => (
  // FIXME: flip z properly
  ((x, xo), (y, yo), (-z, zo)).sorted(key: it => it.at(1)).map(it => it.at(0))
)

#let canvas(dim, transform-fn, rotate-fn, scale-fn) = p => scale-fn(
  ortho-proj(
    dim,
    rotate-fn(transform-fn(p)),
  ),
)

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
      let axis-size = length-vec(sum-vec(start, end.map(i => -i)))
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
