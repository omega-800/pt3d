#import "render.typ": *
#import "elem.typ": *
#import "style.typ": *
#import "linalg.typ": *

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

#let canvas((xd, yd, zd)) = {
  let on-canvas = ((x, y, z)) => ortho-proj(
    (xd, yd, zd),
    rotate(calc.pi / 6, (
      x,
      y,
      z,
    )),
  ).map(d => 50% + (d / 2 * 100%))
  (on-canvas,)
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

  let content = ()
  let offset = 0pt
  if title != none {
    let title-elem = block(width: 100%, align(center, title))
    content.push(title-elem)
    offset = measure(title-elem).height
  }
  let cvs = canvas(dim)
  let (on-canvas,) = cvs
  let ctx = (dim, ..cvs)
  let (dxx, dxy) = on-canvas((xto, 0, 0))
  let (dyx, dyy) = on-canvas((0, yto, 0))
  let (dzx, dzy) = on-canvas((0, 0, zto))
  // TODO: skew offset
  content.push(
    block(fill: fill, width: 100%, height: 100% - offset, [
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
