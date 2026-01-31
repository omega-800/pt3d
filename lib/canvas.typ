#import "proj.typ": *

#let out-of-bounds = x => x > 100% or x < 0%
#let overflow-correction = ns => {
  let s = ns.filter(out-of-bounds).sorted()
  let high = calc.max(s.last(default: 100%), 100%)
  let low = calc.min(s.first(default: 0%), 0%)
  let span = high - low
  (
    span / 2,
    -low / span * 100%,
    (100% - high) / span * 100%,
    (100% / span) * 100%,
  )
}
#let rescale = ((xtrsh, xlo, xhi, xscale), (ytrsh, ylo, yhi, yscale)) => (
  (x, y),
) => {
  let adjust = (val, trsh, ol, oh, s) => {
    let av = s * val
    (if av > trsh { av + oh } else { av + ol })
  }
  (adjust(x, xtrsh, xlo, xhi, xscale), adjust(y, ytrsh, ylo, yhi, yscale))
}
#let canvas((xd, yd, zd), (xo, yo, zo), rotate-fn, scale-fn) = (
  (x, y, z),
) => scale-fn(
  ortho-proj(
    (xd, yd, zd),
    rotate-fn(
      // FIXME: y and z flipped
      ((x, xo), (y, yo), (z, zo))
        .sorted(key: it => it.at(1))
        .map(it => it.at(0)),
    ),
  ),
)

