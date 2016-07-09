package = "mad"
version = "scm-1"

source = {
   url = "",
}
description = {
   summary = "LA's utilities",
   license = "-",
}
dependencies = {
   "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    ["mad.init"] = "init.lua",
  },
}