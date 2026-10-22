-- a status line theme made only of the terminal's own text colour, reversed for the mode block. Lualine's 16color
-- theme uses the bright black slot for the inactive parts, which reads as faint grey on light backgrounds
local plain = { fg = "NONE", bg = "NONE" }
local mode = { fg = "NONE", bg = "NONE", gui = "bold,reverse" }
local section = { a = mode, b = { fg = "NONE", bg = "NONE", gui = "bold" }, c = plain }
local high_contrast = {
	normal = section,
	insert = section,
	visual = section,
	replace = section,
	command = section,
	inactive = { a = plain, b = plain, c = plain },
}

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = high_contrast,
				-- plain bars between sections: the angled separators need the coloured blocks this theme leaves out
				component_separators = "|",
				section_separators = "",
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {}, -- defaults show add/change/delete markers in the sign column
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {}, -- surfaces the leader-key mappings defined in keymaps.lua as a popup
	},
}
