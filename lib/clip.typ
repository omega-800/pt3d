#import "util.typ": *

#let clip-line(
  (out-of-bounds, dim, intersection-canvas, noclip),
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
        lines.last().push(f)
        lines.last().push(intersection-canvas(f, t).at(1))
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

#let clip-plane(
  (noclip, out-of-bounds, dim, intersection-canvas),
  pts,
) = {
  if noclip or not pts.any(out-of-bounds) {
    pts
  } else {
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

#let clip-vertices(ctx, vertices) = {
  vertices.map(f => clip-plane(ctx, f)).filter(f => f.len() > 0)
}
