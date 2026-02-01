#import "linalg.typ": *

#let eval-plane((on-canvas, _, dim, ..x), elem) = {
  // FIXME: d doesn't adjust to scale?
  // TODO: use canonical cube?
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


