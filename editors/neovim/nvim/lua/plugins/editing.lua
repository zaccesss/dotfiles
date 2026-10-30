return {
	{
		-- typing an opening bracket or quote adds its closing one
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		-- tidies a file's layout on save with the language's own formatter. Only a formatter that
		-- is installed runs. A project's own one in node_modules is used before any other, so a
		-- project's style always wins. The language servers' formatting is left out for the
		-- same reason: it can disagree with the project's formatter
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format", "black", stop_after_first = true },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				rust = { "rustfmt" },
				go = { "gofmt" },
				sh = { "shfmt" },
			},
			format_on_save = { timeout_ms = 1000, lsp_format = "never" },
			notify_no_formatters = false,
		},
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format this file",
			},
		},
	},
	{
		-- every error and warning in the project in one list
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Errors in the project" },
			{ "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Errors in this file" },
		},
	},
}
