#let load-obj(path) = {
  // TODO: bruh i could've just used split(" ") and split("/")...
  // TODO: redo if i get the time to
  let txt = read(path)
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
      ).map(i => if i == none { none } else { int(cap.at(i)) })
      vertices.push((v1, v2, v3).map(i => vs.at(i - 1)))

      // ns
      // } else if line.starts-with("l ") {
      // } else if line.starts-with("vp ") {
    }
  }
  vertices
}
