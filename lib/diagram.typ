#import "render.typ": *
#import "elem.typ": *
#import "style.typ": *
#import "linalg.typ": *
#import "canvas.typ": *

// https://www.mauriciopoppe.com/notes/computer-graphics/viewing/projection-transform/
// http://www.songho.ca/opengl/gl_projectionmatrix.html

#let render-canvas(ctx, title-offset, legend, cycle, fill, stroke, children) = {
  let (xas, yas, zas) = ctx.axes
  let elems = children
    .pos()
    .filter(elem => "type" in elem and elem.type in render)
    .enumerate()
    .map(((i, elem)) => {
      let color = cycle.at(calc.rem(i, cycle.len()))
      if "stroke" in elem and elem.stroke == auto {
        elem.stroke = color
      }
      if "fill" in elem and elem.fill == auto {
        elem.fill = color.transparentize(80%)
      }
      eval-elem.at(elem.type)(ctx, elem)
    })

  let legend-elems = elems.filter(elem => (
    elem.label != none and elem.eval-points.len() > 0
  ))

  elems = (
    ..(xas, yas, zas).map(axis => eval-elem.at(axis.type)(ctx, axis)),
    ..elems,
  )
  let plot = [#for i in elems { render.at(i.type)(ctx, i) }]
  let plot-elem = block(
    fill: fill,
    width: ctx.canvas-dim.width,
    height: ctx.canvas-dim.height,
    plot,
  )
  if legend-elems.len() < 1 {
    return plot-elem
  }
  if not legend.separate {
    return block(
      width: 100%,
      height: 100% - title-offset,
      [
        #place(legend.position, render-legend(
          ctx,
          legend,
          legend-elems,
        ))
        #place(
          top + left,
          plot-elem,
        )
      ],
    )
  }
  let legend-x = legend.position.x
  let legend-y = legend.position.y
  let legend-dir = if legend-x == none and legend-y == none {
    btt
  } else if (legend-y == none) {
    if legend-x == left { ltr } else { rtl }
  } else {
    if legend-y == top { ttb } else { btt }
  }
  let (l-w, l-h) = if legend-dir == ltr or legend-dir == rtl {
    (auto, ctx.canvas-dim.height)
  } else {
    (ctx.canvas-dim.width, auto)
  }
  let legend-elem = render-legend(
    ctx,
    legend,
    legend-elems,
    width: l-w,
    height: l-h,
  )
  let (width, height) = measure(legend-elem)
  let (off-w, off-h) = if legend-dir == ltr or legend-dir == rtl {
    (width, 0pt)
  } else {
    (0pt, height)
  }

  let plot-elem = block(
    fill: fill,
    width: ctx.canvas-dim.width - off-w,
    height: ctx.canvas-dim.height - off-h,
    plot,
  )

  return stack(
    dir: legend-dir,
    legend-elem,
    plot-elem,
  )
}

#let diagram(
  width: 8cm,
  height: 6cm,
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
  rotations: (mat-rotate-iso,),
  noclip: false,
  ..children,
) = context {
  let (title-offset, ctx) = gen-ctx(
    title,
    (width, height),
    (xaxis, yaxis, zaxis),
    rotations,
    children.pos(),
    noclip,
  )

  let content = ()
  let title-elem = block(width: 100%, align(center, pad(5pt, title)))
  content.push(title-elem)
  content.push(render-canvas(
    ctx,
    title-offset,
    legend-def(..legend),
    cycle,
    fill,
    stroke,
    children,
  ))
  box(height: height, width: width, stroke: stroke, stack(..content))
}
