#let mat-mult-vec = (((a, b, c), (d, e, f), (g, h, i)), (x, y, z)) => (
  a * x + b * y + c * z,
  d * x + e * y + f * z,
  g * x + h * y + i * z,
)

#let cross-product = ((x1, y1, z1), (x2, y2, z2)) => (
  y1 * z2 - z1 * y2,
  z1 * x2 - x1 * z2,
  x1 * y2 - y1 * x2,
)

#let cube-vertices = (((xfrom, xto), (yfrom, yto), (zfrom, zto))) => (
  (xfrom, yfrom, zfrom),
  (xto, yfrom, zfrom),
  (xto, yto, zfrom),
  (xfrom, yto, zfrom),
  (xfrom, yfrom, zto),
  (xto, yfrom, zto),
  (xto, yto, zto),
  (xfrom, yto, zto),
)

#let cube-edges = dim => {
  let vertices = cube-vertices(dim)
  (
    (vertices.at(0), vertices.at(1)),
    (vertices.at(1), vertices.at(2)),
    (vertices.at(2), vertices.at(3)),
    (vertices.at(3), vertices.at(0)),
    (vertices.at(6), vertices.at(7)),
    (vertices.at(7), vertices.at(4)),
    (vertices.at(4), vertices.at(5)),
    (vertices.at(5), vertices.at(6)),
    (vertices.at(0), vertices.at(4)),
    (vertices.at(1), vertices.at(5)),
    (vertices.at(2), vertices.at(6)),
    (vertices.at(3), vertices.at(7)),
  )
}

// TODO: 
#let bounds(elem) = {
  ((-5, 5), (-5, 5), (-5, 5))
}

#let intersect-bounds(a, b, larger: true) = {
  let new = ()
  for n in (0, 1, 2) {
    let an = a.at(n)
    let bn = b.at(n)
    if (an == auto) {
      new.push(bn)
    } else if (bn == auto) {
      new.push(an)
    } else if larger {
      new.push((
        calc.min(an.at(0), bn.at(0)),
        calc.max(an.at(1), bn.at(1)),
      ))
    } else {
      new.push((
        calc.max(an.at(0), bn.at(0)),
        calc.min(an.at(1), bn.at(1)),
      ))
    }
  }
  new
}

#let rotate = (n, p) => mat-mult-vec(
  (
    (calc.cos(n), -calc.sin(n), 0),
    (calc.sin(n), calc.cos(n), 0),
    (0, 0, 1),
  ),
  mat-mult-vec(
    (
      (calc.cos(n), 0, calc.sin(n)),
      (0, 1, 0),
      (-calc.sin(n), 0, calc.cos(n)),
    ),
    mat-mult-vec(
      (
        (1, 0, 0),
        (0, calc.cos(n), -calc.sin(n)),
        (0, calc.sin(n), calc.cos(n)),
      ),
      p,
    ),
  ),
)
// #let rotate = (n, p) => mat-mult-vec(
//   (
//     (calc.cos(n), -calc.sin(n), calc.sin(n)),
//     (calc.sin(n), calc.cos(n), -calc.sin(n)),
//     (-calc.sin(n), calc.sin(n), calc.cos(n)),
//   ),
//   p,
// )
