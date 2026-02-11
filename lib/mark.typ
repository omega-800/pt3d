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

#let render-circle((pt-to-ratio, ..a), radius, (x, y), stroke) = {
  let (cs-x, cs-y) = pt-to-ratio(((x - radius) * 1pt, (y - radius) * 1pt))
  place(dx: cs-x, dy: cs-y, circle(fill: stroke, radius: radius * 1pt))
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

#let marks = (
  ">": _ => ">",
  "|>": _ => "|>",
  "|": _ => "|",
  "-": _ => "-",
  "x": _ => "x",
  "+": _ => "+",
  ",": _ => ",",
  ".": _ => ".",
  "o": _ => "o",
  "O": _ => "O",
  "*": _ => "*",
  "^": _ => "^",
  "v": _ => "v",
  "<": _ => "<",
  // TODO: a3-6
  // TODO: p5-8
  // TODO: s3-6
)
