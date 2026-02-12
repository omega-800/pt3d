#import "linalg.typ": *
#import "util.typ": *

#let render-label((on-canvas, ..x), (label, position)) = {
  let (dx, dy) = on-canvas(position)
  let (width, height) = measure(label)
  place(
    dx: dx - width / 2,
    dy: dy - height / 2,
    label,
  )
}

#let render-tip(ctx, tip, start, end, stroke) = {
  let (on-canvas, map-point-pt, pt-to-ratio) = ctx
  let c-start = on-canvas(start)
  let c-end = on-canvas(end)
  let ptstart = map-point-pt(c-start)
  let ptend = map-point-pt(c-end)
  let int-to-ratio = ((x, y)) => pt-to-ratio((x * 1pt, y * 1pt))
  if type(tip) == function {
    render-label(ctx, (label: tip(stroke, end), position: end))
  } else {
    let (x, y) = ptend
    let d = map-point-pt(direction-vec(c-end, c-start))
    let theta = atan2(..d.rev())
    let phi = calc.pi / 6
    let (ptl1, ptl2) = (theta + phi, theta - phi).map(a => (
      ((x + 5 * calc.sin(a)), (y + 5 * calc.cos(a)))
    ))
    let (l1, l2) = (ptl1, ptl2).map(int-to-ratio)
    let (perpf, perpt) = perpendicular-2d(
      ptstart,
      ptend,
      ptend,
      6,
    ).map(int-to-ratio)
    let (scaledf, scaledt) = apply-2d-scale-to-3d(
      (start, end),
      (ptstart, ptend),
      rescale-line(ptstart, ptend, 15),
    ).map(on-canvas)
    if tip == ">" {
      place(path-curve(stroke: stroke, l1, c-end, l2))
    } else if tip == "|>" {
      place(polygon(stroke: stroke, fill: stroke, l1, c-end, l2))
    } else if tip == "|" {
      place(line(stroke: stroke, start: perpf, end: perpt))
    } else if tip == "-" {
      place(line(stroke: stroke, start: scaledf, end: scaledt))
    } else if tip == "x" {
      let phi = calc.pi / 4
      let (ptxl1, ptxl2) = (theta + phi, theta - phi).map(a => (
        ((x + 5 * calc.sin(a)), (y + 5 * calc.cos(a)))
      ))
      let (l1f, l1t) = rescale-line(ptxl1, ptend, 10).map(int-to-ratio)
      let (l2f, l2t) = rescale-line(ptxl2, ptend, 10).map(int-to-ratio)
      place(path-curve(stroke: stroke, l1f, l1t))
      place(path-curve(stroke: stroke, l2f, l2t))
    } else if tip == "+" {
      place(line(stroke: stroke, start: perpf, end: perpt))
      place(line(stroke: stroke, start: scaledf, end: scaledt))
    } else if tip == "," {
      render-circle(ctx, 1, ptend, stroke)
    } else if tip == "." {
      render-circle(ctx, 2, ptend, stroke)
    } else if tip == "o" {
      render-circle(ctx, 3, ptend, stroke)
    } else if tip == "O" {
      render-circle(ctx, 4, ptend, stroke)
    }
  }
}

#let render-arrow(ctx, elem) = {
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

#let render-circle(ctx, elem) = {
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

#let render-polygon(ctx, elem) = {
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

#let render-square(ctx, elem) = {
  let (fill, stroke, from, to) = elem.mark
  // TODO:
}

#let render-text(ctx, elem) = {
  let (fill, stroke, from, to) = elem.mark
  // TODO: size, 3d, etc
  // FIXME: hacky
  render-label(ctx, (label: elem.body, position: to))
}

#let render-mark = (ctx, elem) => {
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

#let mark = (
  fill: auto,
  stroke: auto,
  from: none,
  to: none,
) => (
  fill: fill,
  stroke: stroke,
  from: from,
  to: to,
)

#let arrow-mark = (
  mark,
  flat: false,
  size: 4pt,
  closed: false,
  angle: 30deg,
  rotate: 0deg,
) => (
  type: "arrow",
  flat: flat,
  size: size,
  mark: mark,
  closed: closed,
  angle: angle,
  rotate: rotate,
)

#let circle-mark = (
  mark,
  flat: false,
  size: 4pt,
) => (
  type: "circle",
  mark: mark,
  flat: flat,
  size: size,
)

#let polygon-mark = (
  mark,
  flat: false,
  size: 4pt,
  n: 5,
  inset: 0%,
  rotate: 0deg,
) => (
  type: "polygon",
  mark: mark,
  flat: flat,
  size: size,
  n: n,
  inset: inset,
  rotate: rotate,
)

#let square-mark = (
  mark,
  flat: false,
  size: 4pt,
  height: 4pt,
) => (
  type: "square",
  mark: mark,
  flat: flat,
  size: size,
  height: height,
)

#let text-mark = (
  mark,
  size: 4pt,
  flat: false,
  body: auto,
) => (
  type: "text",
  mark: mark,
  flat: flat,
  size: size,
  body: body,
)

#let star-mark = polygon-mark.with(inset: 40%)

#let asterisk-mark = polygon-mark.with(inset: 100%)

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
