
// TODO:

// #let cube() = {}

// #let sphere() = {}

// https://github.com/cranberrymuffin/valentine
#let heart(u: 32, v: 16) = {
  // TODO: direction, size
  let vertices = ()

  let u-step = (2 * calc.pi) / u
  let v-step = calc.pi / v

  let vi = 0
  while vi <= v {
    let v = vi * v-step
    let ui = 0

    while ui <= u {
      let u = ui * u-step

      let x = calc.sin(v) * (15 * calc.sin(u) - 4 * calc.sin(3 * u))
      let z = 8 * calc.cos(v)
      let y = (
        calc.sin(v)
          * (
            15 * calc.cos(u)
              - 5 * calc.cos(2 * u)
              - 2 * calc.cos(3 * u)
              - calc.cos(2 * u)
          )
      )

      vertices.push((x, y, z))
      ui += 1
    }
    vi += 1
  }

  let indices = ()

  let vi = 0
  while vi < v {
    let ui = 0

    while ui < u {
      let current = vi * (u + 1) + ui
      let next = current + u + 1

      indices.push((current, current + 1, next))
      indices.push((next, current + 1, next + 1))
      ui += 1
    }
    vi += 1
  }

  let points = ()

  for (a, b, c) in indices {
    points.push((vertices.at(a), vertices.at(b), vertices.at(c)))
  }

  points
}
