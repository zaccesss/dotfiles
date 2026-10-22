local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- share the system clipboard, matching every other app
opt.ignorecase = true
opt.smartcase = true -- case-sensitive only when the search itself has a capital letter
opt.termguicolors = false -- use the terminal's own 16 colours, so Neovim matches the terminal palette exactly
opt.signcolumn = "yes" -- always reserve the gutter so LSP diagnostics never shift text
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.wrap = false
opt.undofile = true -- persistent undo across sessions

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- real per-language exceptions, tabstop 2 is wrong for these.
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "c", "cpp" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "
