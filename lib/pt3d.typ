#import "render.typ": *
#import "elem.typ": *
#import "style.typ": *
#import "linalg.typ": *
#import "proj.typ": *

// https://www.mauriciopoppe.com/notes/computer-graphics/viewing/projection-transform/
// http://www.songho.ca/opengl/gl_projectionmatrix.html

// #let pat = tiling(
//   size: (5pt, 4pt),
//   place(
//     [
//       #place(line(start: (0pt, 0pt), end: (0pt, 4pt)))
//       #place(dy: 2pt, line(length: 5pt))
//     ],
//   ),
// )


// #let axis-pos(axis, (from, to)) = {
//   let abs-pos = 0
//   if not "position" in axis or axis.position == auto {
//     if from > 0 {
//       abs-pos = from
//     } else if to < 0 {
//       abs-pos = to
//     } else {
//       abs-pos = 0
//     }
//   } else { abs-pos = axis.position }
//   // TODO: handle negative
//   let span = to - from
//   return ((-from) / span) * 100%
// }

#let out-of-bounds = x => x > 100% or x < 0%
#let overflow-correction = ns => {
  let s = ns.filter(out-of-bounds).sorted()
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
#let rotate3d = ((x, y, z)) => rotate(calc.pi / 6, (x, y, z))
#let canvas((xd, yd, zd), scale-fn) = ((x, y, z)) => {
  scale-fn(ortho-proj(
    (xd, yd, zd),
    rotate3d((x, y, z)),
  ))
}

#let diagram(
  width: 6cm,
  height: 4cm,
  title: none,
  legend: (:),
  grid: auto,
  xaxis: (:),
  yaxis: (:),
  zaxis: (:),
  margin: 6%,
  cycle: petroff10,
  fill: none,
  stroke: none,
  ..children,
) = context {
  // TODO: refactor axis creation, fill in defaults only as soon as known
  let xas = axis(kind: "x", ..xaxis)
  let yas = axis(kind: "y", ..yaxis)
  let zas = axis(kind: "z", ..zaxis)
  let xlim = xas.lim
  let ylim = yas.lim
  let zlim = zas.lim
  let dim = (xlim, ylim, zlim)
  for c in children.pos() {
    dim = intersect-bounds(dim, bounds(c))
  }
  dim = intersect-bounds(dim, (xlim, ylim, zlim), larger: false)
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim
  xas.lim = (xfrom, xto)
  yas.lim = (yfrom, yto)
  zas.lim = (zfrom, zto)

  // TODO: only include rendered points
  let plot-extremes = cube-vertices(dim)
    .map(rotate3d)
    .map(p => ortho-proj(
      dim,
      p,
    ).map(i => i * 100%))

  let on-canvas = canvas(dim, rescale(
    overflow-correction(plot-extremes.map(((x, y)) => x)),
    overflow-correction(plot-extremes.map(((x, y)) => y)),
  ))
  // panic(
  //   plot-extremes,
  //   overflow-correction(plot-extremes.map(((x, y)) => x)),
  //   overflow-correction(plot-extremes.map(((x, y)) => y)),
  //   cube-vertices(dim).map(rotate3d).map(on-canvas),
  // )

  let ctx = (on-canvas, rotate3d, dim, (xas, yas, zas))
  let (dxx, dxy) = on-canvas((xto, 0, 0))
  let (dyx, dyy) = on-canvas((0, yto, 0))
  let (dzx, dzy) = on-canvas((0, 0, zto))

  let content = ()
  let offset = 0pt
  if title != none {
    let title-elem = block(width: 100%, align(center, title))
    content.push(title-elem)
    offset = measure(title-elem).height
  }
  // panic((100% / x-overflow) * 100%, (100% / y-overflow) * 100%)
  content.push(
    block(fill: fill, width: 100%, height: 100% - offset, stroke: stroke, [
      #for xa in xas.instances {
        render(ctx, (:..xas, ..xa))
      }
      #for ya in yas.instances {
        render(ctx, (:..yas, ..ya))
      }
      #for za in zas.instances {
        render(ctx, (:..zas, ..za))
      }

      #for c in children.pos() {
        render(ctx, c)
      }
    ]),
  )
  box(height: height, width: width, stack(..content))
}
