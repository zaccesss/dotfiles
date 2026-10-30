-- snacks.nvim for five small things in one plugin: a start screen, a file tree, lazygit inside
-- Neovim, indent guides and a quieter message area. Its scrolling, dimming and other animated
-- parts stay off. The indent guides never animate either, so nothing moves on its own.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				header = "Zacess  ·  Neovim",
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ section = "recent_files", title = "Recent files", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},
		-- the file tree is a picker underneath, so the picker is on too
		explorer = { enabled = true },
		picker = { enabled = true },
		lazygit = { enabled = true },
		indent = {
			enabled = true,
			animate = { enabled = false },
		},
		notifier = { enabled = true },
		animate = { enabled = false },
		scroll = { enabled = false },
		dim = { enabled = false },
	},
	keys = {
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File tree",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "lazygit",
		},
		{
			"<leader>n",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Earlier messages",
		},
	},
}
