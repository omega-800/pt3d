#import "render.typ": *
#import "elem.typ": *
#import "style.typ": *
#import "linalg.typ": *
#import "canvas.typ": *

// https://www.mauriciopoppe.com/notes/computer-graphics/viewing/projection-transform/
// http://www.songho.ca/opengl/gl_projectionmatrix.html

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
  let legend = legend-def(..legend)

  let (title-offset, ctx) = gen-ctx(
    title,
    (width, height),
    (xaxis, yaxis, zaxis),
    rotations,
    children.pos(),
    noclip,
  )
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

  let content = ()
  let title-elem = block(width: 100%, align(center, pad(5pt, title)))
  content.push(title-elem)

  let render-with-ctx = elem => render.at(elem.type)(ctx, elem)
  let plot = [#for i in (
    ..(xas, yas, zas).map(elem => render-with-ctx(
      eval-elem.at(elem.type)(ctx, elem),
    )),
    ..elems.map(render-with-ctx),
  ) { i }]

  // FIXME: less scuffedness please
  if legend-elems.len() > 0 {
    if legend.separate {
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

      content.push(
        place(
          stack(
            dir: legend-dir,
            legend-elem,
            block(
              // inset: (x: xpad, y: ypad),
              plot-elem,
            ),
          ),
        ),
      )
    } else {
      let legend-elem = render-legend(
        ctx,
        legend,
        legend-elems,
      )
      let plot-elem = block(
        fill: fill,
        width: ctx.canvas-dim.width,
        height: ctx.canvas-dim.height,
        plot,
      )

      content.push(
        block(
          width: 100%,
          height: 100% - title-offset,
          [
            #place(legend.position, legend-elem)
            #place(
              top + left,
              // dx: xpad,
              // dy: ypad,
              plot-elem,
            )
          ],
        ),
      )
    }
  } else {
    let plot-elem = block(
      fill: fill,
      width: ctx.canvas-dim.width,
      height: ctx.canvas-dim.height,
      plot,
    )

    content.push(
      block(
        width: 100%,
        height: 100% - title-offset,
        place(
          top + left,
          // dx: xpad,
          // dy: ypad,
          plot-elem,
        ),
      ),
    )
  }

  box(height: height, width: width, stroke: stroke, stack(..content))
}
