-- Picks the Zacess colour scheme from the small state file the `zt` command in this repo
-- writes (or from a `zt pin neovim` line in the pins file beside it, which wins), so Neovim switches together with every other tool. The file holds one line: a theme id
-- such as `deep-contrast-dark` keeps that theme fixed, while `auto <dark id> <light id>` follows the
-- system appearance. With no file the theme is Zacess Deep Contrast Dark.
--
-- The file is read again whenever Neovim regains focus, so a `zt` run in another window shows up
-- on return. Running `:colorscheme` by hand stops that until `:ZacessFollow` is run.
local M = {}

local default = "deep-contrast-dark"
local manual = false
local applying = false

local function state_dir()
	if vim.fn.has("win32") == 1 then
		return vim.fs.joinpath(vim.env.LOCALAPPDATA or "", "zacess")
	end
	local base = vim.env.XDG_STATE_HOME
	if not base or base == "" then
		base = vim.fs.joinpath(vim.env.HOME, ".local", "state")
	end
	return vim.fs.joinpath(base, "zacess")
end

local function state_file()
	return vim.fs.joinpath(state_dir(), "theme")
end

-- `zt pin neovim <value>` keeps Neovim on its own choice while everything else follows zt. The
-- pins file holds one `app value` line per pin; the neovim line's words are returned (nil without one)
local function read_pin()
	local f = io.open(vim.fs.joinpath(state_dir(), "pins"), "r")
	if not f then
		return nil
	end
	local found
	for line in f:lines() do
		local words = vim.split(vim.trim(line), "%s+", { trimempty = true })
		-- the last line for neovim wins, as it does for zt itself
		if words[1] == "neovim" and #words >= 2 then
			found = { unpack(words, 2) }
		end
	end
	f:close()
	return found
end

local function read_state()
	local f = io.open(state_file(), "r")
	if not f then
		return { default }
	end
	local line = f:read("*l") or ""
	f:close()
	local words = vim.split(vim.trim(line), "%s+", { trimempty = true })
	if #words == 0 then
		return { default }
	end
	return words
end

-- each check asks the system directly, since Neovim in a terminal has no event of its own for a
-- change of appearance
local function system_is_dark()
	if vim.fn.has("mac") == 1 then
		return vim.trim(vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })) == "Dark"
	elseif vim.fn.has("win32") == 1 then
		local out = vim.fn.system({
			"reg", "query", [[HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize]],
			"/v", "AppsUseLightTheme",
		})
		return out:match("REG_DWORD%s+0x0%f[%W]") ~= nil
	end
	if vim.fn.executable("gsettings") == 1 then
		local scheme = vim.fn.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" })
		if vim.v.shell_error == 0 then
			return scheme:match("dark") ~= nil
		end
	end
	return true
end

-- the scheme a pin or the state file asks for. A pin for Neovim's own theme also gives the
-- background the built-in default scheme should take
function M.wanted()
	local words = read_pin() or read_state()
	if words[1] == "default" then
		return "default", system_is_dark() and "dark" or "light"
	elseif words[1] == "default-dark" then
		return "default", "dark"
	elseif words[1] == "default-light" then
		return "default", "light"
	end
	if words[1] == "auto" then
		local dark = words[2] or "deep-contrast-dark"
		local light = words[3] or "deep-contrast-light"
		return "zacess-" .. (system_is_dark() and dark or light)
	end
	return "zacess-" .. words[1]
end

function M.apply()
	if manual then
		return
	end
	local name, background = M.wanted()
	-- changing the background reloads the scheme, which fires ColorScheme; marking it as zt's own
	-- change keeps that from counting as a scheme chosen by hand
	applying = true
	if background and vim.o.background ~= background then
		vim.o.background = background
	end
	if vim.g.colors_name == name then
		applying = false
		return
	end
	local ok = pcall(vim.cmd.colorscheme, name)
	if not ok then
		pcall(vim.cmd.colorscheme, "zacess-" .. default)
	end
	applying = false
end

function M.setup()
	vim.o.termguicolors = true
	M.apply()
	local group = vim.api.nvim_create_augroup("ZacessTheme", { clear = true })
	vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = M.apply })
	-- a scheme chosen by hand wins until :ZacessFollow
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			if not applying then
				manual = true
			end
		end,
	})
	vim.api.nvim_create_user_command("ZacessFollow", function()
		manual = false
		M.apply()
		vim.notify("Following zt again: " .. (vim.g.colors_name or ""))
	end, { desc = "Go back to the Zacess theme zt set, after a manual :colorscheme" })
end

return M
