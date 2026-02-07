#import "linalg.typ": *

#let eval-line((dim, out-of-bounds), elem) = {
  let (p, d) = elem.line
  let points = ()
  for (dir, ddim) in dim.enumerate() {
    if d.at(dir) == 0 { continue }
    for m in (0, 1) {
      let t = (ddim.at(m) - p.at(dir)) / d.at(dir)
      let v = sum-vec(p, d.map(i => i * t))
      if not out-of-bounds(v) {
        points.push(v)
      }
    }
  }
  elem.line = points
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
  elem.plane = points
  elem
}

// TODO: huh, what did i do here again?
#let eval-plane-norm((on-canvas, dim), elem) = {
  // FIXME: d doesn't adjust max scale?
  // TODO: use canonical cube?
  // TODO: intersection-3d
  let ((a, b, c), d) = elem.plane
  let points = ()
  for ((x1, y1, z1), (x2, y2, z2)) in cube-edges(dim) {
    let denom = (a * (x2 - x1) + b * (y2 - y1) + c * (z2 - z1))
    if denom == 0 {
      continue
    }
    let t = (
      -(a * x1 + b * y1 + c * z1 - d) / denom
    )
    if t >= 0 and t <= 1 {
      points.push((
        (1 - t) * x1 + t * x2,
        (1 - t) * y1 + t * y2,
        (1 - t) * z1 + t * z2,
      ))
    }
  }
  elem.plane = points
  elem
}

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

#let eval-axis(ctx, elem) = {
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

#let eval-points = (
  ctx,
  elem,
) => {
  if "axis" in elem {
    eval-axis(ctx, elem)
  } else if "path" in elem {
    elem.path
  } else if "polygon" in elem {
    elem.polygon
  } else if "vec" in elem {
    elem.vec
  } else if "lineplot" in elem {
    let (x, y, z) = elem.lineplot
    x.zip(y, z)
  } else if "planeplot" in elem {
    let (x, y, z, _) = elem.planeplot
    x.zip(y, z)
  } else {
    ()
    // } else if "plane" in elem {
    // } else if "line" in elem {
    // } else if "planeparam" in elem {
    // } else if "lineparam" in elem {
  }
}

#let minmax = (((xmin, ymin, zmin), (xmax, ymax, zmax)), (x, y, z)) => (
  (calc.min(xmin, x), calc.min(ymin, y), calc.min(zmin, z)),
  (calc.max(xmax, x), calc.max(ymax, y), calc.max(zmax, z)),
)

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
    (
      acc,
      cur,
    ) => minmax(acc, cur),
  )
}
