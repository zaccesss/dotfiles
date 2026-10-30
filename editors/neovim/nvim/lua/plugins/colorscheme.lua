-- the eight Zacess colour schemes come from zacess.nvim, pinned to its release. config/theme.lua picks
-- one from the state file the zt command writes, Zacess Deep Contrast Dark when there is none. The
-- earlier colors/high-contrast.lua stays available through :colorscheme high-contrast.
return {
	{
		"zacesshq/zacess.nvim",
		version = "0.6.0",
		lazy = false,
		priority = 1000,
		config = function()
			require("config.theme").setup()
		end,
	},
}
