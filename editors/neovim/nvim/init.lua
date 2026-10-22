-- entry point: core settings load first, then the plugin manager and plugin specs.
require("config.options")
require("config.keymaps")
require("config.lazy")
