local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- lazy-lock.json is the repo's copy, shared by every machine. lazy rewrites it from the plugins
-- installed here after an install or a clean too, which quietly put a machine's older commits back
-- over newer pins from the repo. lazy writes it after its own events fire, so the file is
-- remembered at start and put back as nvim exits unless an update or a sync ran in this session
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
local function read_lock()
	return vim.fn.filereadable(lockfile) == 1 and vim.fn.readfile(lockfile, "b") or nil
end
local pinned = read_lock()
local moved = false
vim.api.nvim_create_autocmd("User", {
	pattern = { "LazyUpdatePre", "LazySyncPre" },
	callback = function()
		moved = true
	end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		if not moved and pinned and not vim.deep_equal(read_lock(), pinned) then
			vim.fn.writefile(pinned, lockfile, "b")
		end
	end,
})

require("lazy").setup("plugins", {
	install = { colorscheme = { "high-contrast" } },
	checker = { enabled = true, notify = false }, -- silent background update check, no popup spam
})
