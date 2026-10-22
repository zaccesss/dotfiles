-- the High Contrast scheme lives in colors/high-contrast.lua and uses the terminal's own 16 colours, so it needs no
-- plugin. Applying it here keeps it the last word on colours once the plugins have loaded. Light and dark come from
-- the terminal palette itself, so there is nothing to switch when the system appearance changes.
return {
	{
		dir = vim.fn.stdpath("config"),
		name = "high-contrast",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("high-contrast")
		end,
	},
}
