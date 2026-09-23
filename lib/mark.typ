#import "linalg.typ": *
#import "util.typ": *

/// Renders a text label at its 3d position on the canvas
///
/// -> content
#let render-label(
  /// Canvas context
  /// -> dictionary
  (on-canvas, ..x),
  /// (label, position) pair
  /// -> array
  (label, position),
) = {
  let (dx, dy) = on-canvas(position)
  let (width, height) = measure(label)
  place(
    dx: dx - width / 2,
    dy: dy - height / 2,
    label,
  )
}

/// Renders an arrow mark at the end of a line segment
///
/// -> content
#let render-arrow(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Mark element as returned by a mark constructor
  /// -> dictionary
  elem,
) = {
  // TODO: 3d
  let (on-canvas, map-point-pt, pt-to-ratio) = ctx
  let (fill, stroke, from, to) = elem.mark
  let (r-from, r-to) = (from, to).map(on-canvas)
  let (pt-from, pt-to) = (r-from, r-to).map(map-point-pt)
  let int-to-ratio = ((x, y)) => pt-to-ratio((x * 1pt, y * 1pt))
  let size = elem.size / 1pt

  let (x, y) = pt-to
  let d = map-point-pt(direction-vec(r-to, r-from))
  let theta = atan2(..d.rev())
  let phi = elem.angle.rad()
  let rot = elem.rotate.rad()
  // TODO: rotate
  let (ptl1, ptl2) = (
    theta + phi + rot,
    theta - phi + rot,
  ).map(a => (
    // TODO: properly calculate size
    ((x + size * calc.sin(a)), (y + size * calc.cos(a)))
  ))
  let (l1, l2) = (ptl1, ptl2).map(int-to-ratio)
  place(if elem.closed {
    polygon(stroke: stroke, fill: fill, l1, r-to, l2)
  } else {
    path-curve(stroke: stroke, l1, r-to, l2)
  })
}

/// Renders a circle mark at a point
///
/// -> content
#let render-circle(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Mark element as returned by a mark constructor
  /// -> dictionary
  elem,
) = {
  // TODO: 3d
  let (on-canvas, map-point-pt, pt-to-ratio) = ctx
  let (fill, stroke, from, to) = elem.mark
  let (x, y) = map-point-pt(on-canvas(to))
  let size = elem.size / 2

  let (cs-x, cs-y) = pt-to-ratio((x * 1pt - size, y * 1pt - size))
  place(dx: cs-x, dy: cs-y, circle(
    stroke: stroke,
    fill: fill,
    radius: size,
  ))
}

/// Renders a regular polygon mark at a point
///
/// -> content
#let render-polygon(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Mark element as returned by a mark constructor
  /// -> dictionary
  elem,
) = {
  let (fill, stroke, from, to) = elem.mark
  // TODO: 3d
  let (on-canvas, map-point-pt, pt-to-ratio) = ctx
  let (fill, stroke, from, to) = elem.mark
  let (r-from, r-to) = (from, to).map(on-canvas)
  let (pt-from, pt-to) = (r-from, r-to).map(map-point-pt)
  let int-to-ratio = ((x, y)) => pt-to-ratio((x * 1pt, y * 1pt))
  let int-to-ratio = ((x, y)) => pt-to-ratio((x * 1pt, y * 1pt))
  let size = elem.size / 1.5pt

  let (x, y) = pt-to
  let d = map-point-pt(direction-vec(r-from, r-to))
  let theta = atan2(..d.rev())
  let phi = (360deg / elem.n).rad()
  let rot = elem.rotate.rad()
  let pts = range(0, elem.n).map(n => {
    let a = theta + n * phi + rot
    (
      (x + size * calc.sin(a)),
      (y + size * calc.cos(a)),
    )
  })
  let with-inset = if elem.inset == 0% {
    pts.map(int-to-ratio)
  } else {
    ((pts.last(), pts.first()), ..pts.windows(2))
      .map(((f, t)) => {
        let m = mid-vec(f, t)
        (
          f,
          // FIXME: check if this still works
          rescale-line(
            m,
            pt-to,
            distance-vec(m, pt-to) * (elem.inset / 100%),
          ).last(),
        ).map(int-to-ratio)
      })
      .join()
  }
  // FIXME: cutoff with s3
  place(polygon(stroke: stroke, fill: fill, ..with-inset))
}

/// Renders a square mark at a point
///
/// -> content
#let render-square(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Mark element as returned by a mark constructor
  /// -> dictionary
  elem,
) = {
  let (fill, stroke, from, to) = elem.mark
  // TODO:
}

/// Renders a text mark at a point
///
/// -> content
#let render-text(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Mark element as returned by a mark constructor
  /// -> dictionary
  elem,
) = {
  let (fill, stroke, from, to) = elem.mark
  // TODO: size, 3d, etc
  // FIXME: hacky
  render-label(ctx, (label: elem.body, position: to))
}

/// Dispatches the rendering of a mark element to the correct render function
///
/// -> content
#let render-mark(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Mark element, can be `none`
  /// -> dictionary | content | none
  elem,
) = {
  if elem != none and elem.mark != none {
    if type(elem.mark) == dictionary {
      (
        "arrow": render-arrow,
        "circle": render-circle,
        "polygon": render-polygon,
        "square": render-square,
        "text": render-text,
      ).at(elem.mark.type)(ctx, elem.mark)
    } else {
      // FIXME: hacky
      render-label(ctx, (label: elem.mark, position: elem.to))
    }
  }
}

/// Constructs a mark element that the mark constructors take. It holds the
/// color and position of the mark.
///
/// -> dictionary
#let mark(
  /// Fill color of the mark
  /// -> auto | none | color | gradient | tiling
  fill: auto,
  /// Stroke of the mark
  /// -> auto | none | length | color | gradient | stroke | tiling | dictionary
  stroke: auto,
  /// Start of the line segment the mark belongs to
  /// -> auto | vector
  from: none,
  /// End of the line segment the mark belongs to
  /// -> auto | vector
  to: none,
) = (
  fill: fill,
  stroke: stroke,
  from: from,
  to: to,
)

/// Constructs an arrow mark element
///
/// -> dictionary
#let arrow-mark(
  /// Mark element as returned by @mark
  /// -> dictionary
  mark,
  /// Whether the arrow is flat
  /// -> bool
  flat: false,
  /// Size of the arrow head
  /// -> length
  size: 4pt,
  /// Whether the arrow head is filled
  /// -> bool
  closed: false,
  /// Opening angle of the arrow head
  /// -> angle
  angle: 30deg,
  /// Rotation of the arrow head
  /// -> angle
  rotate: 0deg,
) = (
  type: "arrow",
  flat: flat,
  size: size,
  mark: mark,
  closed: closed,
  angle: angle,
  rotate: rotate,
)

/// Constructs a circle mark element
///
/// -> dictionary
#let circle-mark(
  /// Mark element as returned by @mark
  /// -> dictionary
  mark,
  /// Whether the circle is flat
  /// -> bool
  flat: false,
  /// Diameter of the circle
  /// -> length
  size: 4pt,
) = (
  type: "circle",
  mark: mark,
  flat: flat,
  size: size,
)

/// Constructs a regular polygon mark element
///
/// -> dictionary
#let polygon-mark(
  /// Mark element as returned by @mark
  /// -> dictionary
  mark,
  /// Whether the polygon is flat
  /// -> bool
  flat: false,
  /// Size of the polygon
  /// -> length
  size: 4pt,
  /// Number of vertices
  /// -> int
  n: 5,
  /// Edge inset of the polygon. A value of 100% produces an asterisk.
  /// -> ratio
  inset: 0%,
  /// Rotation of the polygon
  /// -> angle
  rotate: 0deg,
) = (
  type: "polygon",
  mark: mark,
  flat: flat,
  size: size,
  n: n,
  inset: inset,
  rotate: rotate,
)

/// Constructs a square mark element
///
/// -> dictionary
#let square-mark(
  /// Mark element as returned by @mark
  /// -> dictionary
  mark,
  /// Whether the square is flat
  /// -> bool
  flat: false,
  /// Size of the square
  /// -> length
  size: 4pt,
  /// Height of the square
  /// -> length
  height: 4pt,
) = (
  type: "square",
  mark: mark,
  flat: flat,
  size: size,
  height: height,
)

/// Constructs a text mark element
///
/// -> dictionary
#let text-mark(
  /// Mark element as returned by @mark
  /// -> dictionary
  mark,
  /// Text size
  /// -> length
  size: 4pt,
  /// Whether the text is flat
  /// -> bool
  flat: false,
  /// Arbitrary content to render as mark. If `auto`, the mark is used.
  /// -> auto | content
  body: auto,
) = (
  type: "text",
  mark: mark,
  flat: flat,
  size: size,
  body: body,
)

/// A star mark, a @polygon-mark with 40% inset
///
/// -> function
#let star-mark = polygon-mark.with(inset: 40%)

/// An asterisk mark, a @polygon-mark with 100% inset
///
/// -> function
#let asterisk-mark = polygon-mark.with(inset: 100%)

/// A dictionary of all marks by name or symbol.
///
/// Any of these can be used wherever a mark is accepted, e.g. @lineplot.mark.
/// Additionally, any string can be used as a text mark.
///
/// -> dictionary
#let marks = (
  arrow: arrow-mark,
  ">": arrow-mark,
  "|>": arrow-mark.with(closed: true),
  "<": arrow-mark.with(rotate: 180deg),
  "<|": arrow-mark.with(rotate: 180deg, closed: true),
  "^": arrow-mark.with(rotate: -90deg),
  "_^": arrow-mark.with(rotate: -90deg, closed: true),
  "v": arrow-mark.with(rotate: 90deg),
  "_v": arrow-mark.with(rotate: 90deg, closed: true),
  circle: circle-mark,
  ",": circle-mark.with(size: 1pt),
  ".": circle-mark.with(size: 2pt),
  "o": circle-mark,
  "O": circle-mark.with(size: 6pt),
  // TODO:
  // "s": square-mark,
  "s": polygon-mark.with(n: 4, rotate: 45deg),
  polygon: polygon-mark,
  "t": polygon-mark.with(n: 3),
  "d": polygon-mark.with(n: 4),
  "p3": polygon-mark.with(n: 3),
  "p4": polygon-mark.with(n: 4),
  "p5": polygon-mark.with(n: 5),
  "p6": polygon-mark.with(n: 6),
  "p7": polygon-mark.with(n: 7),
  "p8": polygon-mark.with(n: 8),
  "|": polygon-mark.with(n: 2, rotate: 90deg),
  "-": polygon-mark.with(n: 2),
  star: star-mark,
  "s3": star-mark.with(n: 3),
  "s4": star-mark.with(n: 4),
  "s5": star-mark,
  "s6": star-mark.with(n: 6),
  "s7": star-mark.with(n: 7),
  "s8": star-mark.with(n: 8),
  asterisk: asterisk-mark,
  "+": asterisk-mark.with(n: 4),
  "x": asterisk-mark.with(n: 4, rotate: 45deg),
  "a3": asterisk-mark.with(n: 3),
  "a4": asterisk-mark.with(n: 4),
  "a5": asterisk-mark.with(n: 5),
  "a6": asterisk-mark.with(n: 6),
  "a7": asterisk-mark.with(n: 7),
  "a8": asterisk-mark.with(n: 8),
  "text": text-mark,
  "none": mark => none,
)
