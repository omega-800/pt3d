#let ortho-proj = (((xmin, xmax), (ymin, ymax), _), (x, y, z)) => (
  (2 * x - xmax - xmin) / (xmax - xmin),
  (2 * y - ymax - ymin) / (ymax - ymin),
)

#let out-of-bounds-2d = x => x > 100% or x < 0%

#let clamp-to-bounds-3d = ((xmin, xmax), (ymin, ymax), (zmin, zmax)) => (
  (x, y, z),
) => (
  calc.clamp(x,xmin, xmax),
  calc.clamp(y,ymin, ymax),
  calc.clamp(z,zmin, zmax),
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
    span / 2,
    -low / span * 100%,
    (100% - high) / span * 100%,
    (100% / span) * 100%,
  )
}

#let rescale = ((xtrsh, xlo, xhi, xscale), (ytrsh, ylo, yhi, yscale)) => (
  (x, y),
) => {
  let adjust = (val, trsh, ol, oh, s) => {
    let av = s * val
    (if av > trsh { av + oh } else { av + ol })
  }
  (adjust(x, xtrsh, xlo, xhi, xscale), adjust(y, ytrsh, ylo, yhi, yscale))
}

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
  ((xmin, xmax), (ymin, ymax), (zmin, zmax)),
) => {
  if not i.plane.hidden and i.plane.position == auto {
    i.plane.position = if i.kind == "x" {
      xmax
    } else if i.kind == "y" {
      ymax
    } else {
      zmin
    }
  }
  if not i.line.hidden and i.line.position.any(p => p == auto) {
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
  i
}

#let axes-defaults = (xaxis, yaxis, zaxis, dim) => {
  let (xlim, ylim, zlim) = dim
  let xas = (
    ..xaxis,
    lim: xlim,
    instances: xaxis.instances.map(i => axis-instance-defaults(i, dim)),
  )
  let yas = (
    ..yaxis,
    lim: ylim,
    instances: yaxis.instances.map(i => axis-instance-defaults(i, dim)),
  )
  let zas = (
    ..zaxis,
    lim: zlim,
    instances: zaxis.instances.map(i => axis-instance-defaults(i, dim)),
  )

  (xas, yas, zas)
}
