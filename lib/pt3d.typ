// TODO: export the things that need to be exported after code changes
#import "canvas.typ": (
  clamp-to-bounds-3d, ortho-proj, out-of-bounds-2d, out-of-bounds-3d, rescale,
)
#import "diagram.typ": diagram
#import "elem.typ": (
  axis3d as axis, axisline3d as axisline, axisplane3d as axisplane,
  line3d as line, lineparam3d as lineparam, lineplot3d as lineplot,
  path3d as path, plane3d as plane, planeparam3d as planeparam,
  planeplot3d as planeplot, polygon3d as polygon, vec3d as vec,
  vertices3d as vertices,
)
#import "linalg.typ": *
#import "style.typ": *
#import "fs.typ": *
#import "util.typ": (
  domain, linspace, mid-vec, minmax-vec, n-points-on, n-points-on-cube,
  path-curve, x-y-points,
)
#import "mark.typ": marks
