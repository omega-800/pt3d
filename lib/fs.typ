/// Parses the faces of a `wavefront .obj` string as triangle vertices.
/// Only `v` and `f` lines are parsed.
///
/// ```example
/// #let obj = (
///   "v 0 0 0",
///   "v 3 0 0",
///   "v 0 3 0",
///   "v 0 0 3",
///   "f 1 2 3",
///   "f 1 2 4",
///   "f 1 3 4",
///   "f 2 3 4",
/// ).join("\n")
/// #pt.diagram(
///   pt.vertices(
///     stroke: black,
///     fill: black.transparentize(90%),
///     ..pt.load-obj(obj),
///   ),
/// )
/// ```
///
/// -> array
#let load-obj(
  /// The text content of the `.obj` file
  /// -> str
  txt,
) = {
  // TODO: bruh i could've just used split(" ") and split("/")...
  // TODO: redo if i get the time to
  let df = "(-?\\d\\.?\\d*)"
  let dn = "\\d\\d?\\d?"
  let fc = "((" + dn + ")(/(\\d?\\d?\\d?))?(/(" + dn + "))?)"
  let xyz-reg = df + " " + df + " " + df
  let vs = ()
  let vs-reg = regex(xyz-reg + " ?" + df + "?")
  // let vts = ()
  // let vts-reg = regex(df + " ?" + df + "? ?" + df)
  // let vns = ()
  // let vns-reg = regex(xyz-reg)
  // let vps = ()
  // let vps-reg = regex("")
  // let ls = ()
  // let ls-reg = regex("")
  let fs = ()
  let fs-reg = regex(fc + " " + fc + " " + fc)

  let vertices = ()

  for line in txt.split("\n") {
    if line.starts-with("v ") {
      let (x, y, z, w) = line
        .match(vs-reg)
        .captures
        .map(i => if i == none { 1.0 } else { float(i) })
      vs.push((x, -z, y).map(i => i / w))
      // } else if line.starts-with("vn ") {
      //   let (x, y, z) = line.match(vns-reg).captures.map(float)
      //   vns.push((x, y, z))
      // } else if line.starts-with("vt ") {
      //   let (u, v, w) = line
      //     .match(vts-reg)
      //     .captures
      //     .map(i => if i == none { 0.0 } else { float(i) })
      //   vts.push((u, v, w))
    } else if line.starts-with("f ") {
      let cap = line.match(fs-reg).captures
      let (v1, t1, n1, v2, t2, n2, v3, t3, n3) = (
        1,
        3,
        5,
        7,
        9,
        11,
        13,
        15,
        17,
      ).map(i => if cap.at(i) == none { none } else { int(cap.at(i)) })
      vertices.push((v1, v2, v3).map(i => vs.at(i - 1)))

      // ns
      // } else if line.starts-with("l ") {
      // } else if line.starts-with("vp ") {
    }
  }
  vertices
}

/// Parses a `csv` string as a list of 3d points. The first line is parsed
/// as column labels if `with-labels` is set.
///
/// ```example
/// #let csv = (
///   "1,2,3",
///   "4,5,8",
///   "7,9,0",
///   "2,8,6",
/// ).join("\n")
/// #pt.diagram(
///   pt.path(
///     ..pt.load-csv(csv),
///   ),
/// )
/// ```
///
/// -> array | array (labels, points)
#let load-csv(
  /// The text content of the `csv` file
  /// -> str
  txt,
  /// Separator between columns
  /// -> str
  sep: ",",
  /// Whether to parse the first line as column labels
  /// -> bool
  with-labels: false,
) = {
  let dr = "-?\\d\\.?\\d*"
  let reg = regex(dr + sep + dr + sep + dr)
  let points = ()
  let labels = ()
  let lines = txt.split("\n")
  if lines.first().match(reg) == none and with-labels {
    let parts = lines.first().split(sep)
    if parts.len() == 3 {
      labels = parts
    }
  }
  for line in lines {
    if line.match(reg) != none {
      points.push(line.split(sep).map(float))
    }
  }
  if with-labels {
    (labels, points)
  } else {
    points
  }
}
