#import "util.typ": *

/// Clips a list of 3d points (a polyline) against the bounding volume and
/// splits it into the visible sub-polylines, inserting the intersection
/// points with the volume boundaries.
///
/// -> array
#let clip-line(
  /// Clip context as (out-of-bounds, dim, intersection-canvas, noclip)
  /// -> array
  (out-of-bounds, dim, intersection-canvas, noclip),
  /// 3d points as $(x, y, z)$
  /// -> array
  pts,
) = {
  if noclip or not pts.any(out-of-bounds) {
    (pts,)
  } else {
    let lines = ((),)
    for ((i, f), (j, t)) in pts.enumerate().windows(2) {
      let f-out = out-of-bounds(f)
      let t-out = out-of-bounds(t)
      if f-out and t-out {
        continue
      } else if f-out {
        if lines.last().len() > 0 {
          lines.push(())
        }
        // TODO: optimize
        lines.last().push(intersection-canvas(f, t).at(0))
        if j == pts.len() - 1 {
          lines.last().push(t)
        }
      } else if t-out {
        let inter = intersection-canvas(f, t)
        if inter != none {
          lines.last().push(f)
          // FIXME: intersection-canvas is none
          // TODO: fix this everywhere where intersection-canvas is used
          lines.last().push(inter.at(1))
        }
      } else {
        lines.last().push(f)
        if j == pts.len() - 1 {
          lines.last().push(t)
        }
      }
    }
    lines
  }
}

/// Clips a closed 3d polygon (a plane) against the bounding volume and
/// returns the visible part, or the original polygon if `noclip` is set.
///
/// -> array
#let clip-plane(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// 3d points as $(x, y, z)$
  /// -> array
  pts,
) = {
  if "noclip" not in ctx or ctx.noclip or not pts.any(ctx.out-of-bounds) {
    pts
  } else {
    let (noclip, out-of-bounds, dim, intersection-canvas) = ctx
    let newpts = ()
    for (f, t) in (..pts.windows(2), (pts.last(), pts.first())) {
      // TODO: optimize if i someday will have time left
      let new = intersection-canvas(f, t)
      if new == none { continue }
      for p in new {
        if not newpts.contains(p) and not p == none {
          newpts.push(p)
        }
      }
    }
    newpts
  }
}

/// Clips a list of closed 3d polygons (a group of vertices) against the
/// bounding volume and discards the invisible ones.
///
/// -> array
#let clip-vertices(
  /// Canvas context
  /// -> dictionary
  ctx,
  /// Group of 3d points as $(x, y, z)$
  /// -> array
  vertices,
) = {
  vertices.map(f => clip-plane(ctx, f)).filter(f => f.len() > 0)
}
