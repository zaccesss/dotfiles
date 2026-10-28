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
		opts = {
			-- one sign shape per kind of change, so a hunk reads in the gutter without its colour: gitsigns'
			-- own signs draw the same bar for an addition and a change
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~_" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~_" },
				untracked = { text = "┆" },
			},
			numhl = true, -- the line number takes the hunk's colour as well as the sign
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {}, -- surfaces the leader-key mappings defined in keymaps.lua as a popup
	},
}
