return {
	"nvim-treesitter/nvim-treesitter",
	-- pinned to master: the default "main" branch is a rewrite that dropped the
	-- nvim-treesitter.configs module this config uses. master is still the stable, documented API
	-- most setups target.
	branch = "master",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c", "cpp", "python", "lua", "bash", "typescript", "javascript",
				"tsx", "json", "yaml", "toml", "markdown", "vim", "vimdoc",
			},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
