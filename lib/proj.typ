#let ortho-proj = (((xfrom, xto), (yfrom, yto), _), (x, y, z)) => (
  (2 * x - xto - xfrom) / (xto - xfrom),
  (2 * y - yto - yfrom) / (yto - yfrom),
)

// TODO: eval once before passing to proj-points & render

// NOTE: duh i don't even need this
#let proj-path((on-canvas, ..x), elem) = { elem.path.map(on-canvas) }
#let proj-polygon((on-canvas, ..x), elem) = { elem.polygon.map(on-canvas) }
#let proj-plane(ctx, elem) = { eval-plane(ctx, elem).plane.map(on-canvas) }
#let proj-line((on-canvas, ..x), elem) = { elem.line.map(on-canvas) }
#let proj-axis((on-canvas, ..x), elem) = {
  // TODO: all lines, planes
  let (on-canvas, dim, (xas, yas, zas)) = ctx
  let ((xfrom, xto), (yfrom, yto), (zfrom, zto)) = dim
  let points = ()
  points.push()
}

#let proj-points(ctx, ..children) = {
  children
    .pos()
    .map(elem => if "axis" in elem {
      proj-axis(ctx, elem)
    } else if "path" in elem {
      proj-path(ctx, elem)
    } else if "polygon" in elem {
      proj-polygon(ctx, elem)
    } else if "plane" in elem {
      proj-plane(ctx, elem)
    } else if "line" in elem {
      proj-line(ctx, elem)
    })
}
