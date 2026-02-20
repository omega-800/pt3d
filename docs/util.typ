#import "@preview/tidy:0.4.3"
#import "/lib/pt3d.typ"

#let show-module = module => tidy.show-module(
  tidy.parse-module(
    read("/lib/" + module + ".typ"),
    scope: (pt3d: pt3d),
    preamble: "#import pt3d: *;",
  ),
  style: tidy.styles.default,
)
