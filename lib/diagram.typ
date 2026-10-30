#import "render.typ": *
#import "elem.typ": legend-def
#import "style.typ": *
#import "linalg.typ": *
#import "canvas.typ": *

// https://www.mauriciopoppe.com/notes/computer-graphics/viewing/projection-transform/
// http://www.songho.ca/opengl/gl_projectionmatrix.html

/// Renders the canvas of a @diagram: evaluates the axes and the elements,
/// renders them inside the plot box, and lays out the legend.
///
/// -> content
#let render-canvas(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Height of the title area
  /// -> length
  title-offset,
  /// Legend parameters as returned by @legend-def
  /// -> dictionary
  legend,
  /// Color cycle
  /// -> array
  cycle,
  /// Default fill of the elements
  /// -> auto | none | color | gradient | tiling
  fill,
  /// Default stroke of the elements
  /// -> auto | none | length | color | gradient | stroke | tiling | dictionary
  stroke,
  /// The elements of the plot
  /// -> array
  children,
) = {
  let (xas, yas, zas) = ctx.axes
  let elems = children
    .pos()
    .filter(elem => "type" in elem and elem.type in render)
    .enumerate()
    .map(((i, elem)) => {
      let color = if cycle.len() > 0 {
        cycle.at(calc.rem(i, cycle.len()))
      } else {
        none
      }
      if "stroke" in elem and elem.stroke == auto {
        elem.stroke = color
      }
      if "fill" in elem and elem.fill == auto {
        elem.fill = if color != none {
          color.transparentize(80%)
        } else {
          none
        }
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

/// Creates a 3d plot.
///
/// The elements (@lineplot, @planeplot, @path, @polygon, @vertices, @vec,
/// @line, @plane, @planeparam, @distribution and @quiver) are evaluated, a
/// bounding volume is computed, the scene is rotated and projected onto a 2d
/// canvas, and the elements are rendered.
///
/// ```example
/// #pt.diagram(
///   title: "trippy cube",
///   legend: (separate: true, dir: ltr),
///   pt.polygon(
///     (3, 0, 3),
///     (3, 0, -3),
///     (-3, 0, -3),
///     (-3, 0, 3),
///     fill: red.transparentize(70%),
///   ),
///   pt.path(
///     stroke: red,
///     label: "trippy cube",
///     (-1, -1, 1),
///     (1, -1, 1),
///     (1, 1, 1),
///     (-1, 1, 1),
///     (1, 1, -1),
///     (1, -1, -1),
///     (-1, -1, -1),
///   ),
/// )
/// ```
///
/// -> content
#let diagram(
  /// Width of the diagram
  /// -> length | ratio
  width: 8cm,
  /// Height of the diagram
  /// -> length | ratio
  height: 6cm,
  /// Title of the diagram
  /// -> auto | none | content
  title: none,
  /// Legend parameters, see @legend-def
  /// -> dictionary
  legend: (:),
  /// Whether to draw a grid (not implemented yet)
  /// -> auto | bool
  grid: auto,
  /// Parameters for the x-axis, see @axis
  /// -> dictionary
  xaxis: (:),
  /// Parameters for the y-axis, see @axis
  /// -> dictionary
  yaxis: (:),
  /// Parameters for the z-axis, see @axis
  /// -> dictionary
  zaxis: (:),
  /// Margin around the canvas (not implemented yet)
  /// -> length | ratio
  margin: 6%,
  /// Color cycle, the $n$th element is colored with the $n$th color
  /// -> array
  cycle: petroff10,
  /// Default fill of the elements
  /// -> auto | none | color | gradient | tiling
  fill: none,
  /// Default stroke of the elements
  /// -> auto | none | length | color | gradient | stroke | tiling | dictionary
  stroke: none,
  /// Rotation matrices applied to the scene before projection, see
  /// @mat-rotate-x, @mat-rotate-y, @mat-rotate-z and @mat-rotate-iso
  /// -> array
  rotations: (mat-rotate-iso,),
  /// Whether to disable clipping of the elements at the bounding volume
  /// -> bool
  noclip: false,
  /// Elements to plot
  /// -> array
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
