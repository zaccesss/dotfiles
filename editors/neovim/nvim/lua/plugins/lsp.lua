return {
	{
		"williamboman/mason.nvim",
		config = true, -- runs require("mason").setup() with defaults
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
		opts = {
			-- clangd for C and C++, pyright for Python, ts_ls for TypeScript and JavaScript, lua_ls
			-- for this config itself. These are lspconfig server names,
			-- mason-lspconfig maps each to its own real Mason registry package name internally.
			ensure_installed = { "clangd", "pyright", "ts_ls", "lua_ls" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			-- nvim-lspconfig's old require("lspconfig")[server].setup() framework is deprecated as
			-- of Neovim 0.11, removed in nvim-lspconfig v3. vim.lsp.config/vim.lsp.enable are the
			-- native replacement.
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local servers = { "clangd", "pyright", "ts_ls", "lua_ls" }
			for _, server in ipairs(servers) do
				vim.lsp.config(server, { capabilities = capabilities })
			end
			vim.lsp.enable(servers)

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local opts = { buffer = event.buf }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				end,
			})
		end,
	},
}
