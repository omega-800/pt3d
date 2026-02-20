#import "util.typ": show-module

#let VERSION = toml("/typst.toml").package.version

pt3d #VERSION

#show-module("axes")
#show-module("canvas")
#show-module("clip")
#show-module("diagram")
#show-module("elem")
#show-module("eval")
#show-module("fs")
#show-module("linalg")
#show-module("mark")
#show-module("render")
#show-module("style")
#show-module("util")
