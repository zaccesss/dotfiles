local is_windows = vim.fn.has("win32") == 1

return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			-- native sort, needs ripgrep plus make (macOS and Linux) or cmake (Windows) and a C compiler
			"nvim-telescope/telescope-fzf-native.nvim",
			-- Windows usually has no make, so build with cmake there; the install target copies
			-- the DLL out of build/Release into build/, where fzf_lib.lua looks for it
			build = is_windows
					and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install"
				or "make",
			-- skip the plugin on a machine with no build tools, so a failed build never errors on startup
			cond = function()
				local tool = is_windows and "cmake" or "make"
				if vim.fn.executable(tool) ~= 1 then
					return false
				end
				for _, cc in ipairs({ "cc", "gcc", "clang", "cl" }) do
					if vim.fn.executable(cc) == 1 then
						return true
					end
				end
				return false
			end,
		},
	},
	config = function()
		require("telescope").setup({})
		-- telescope falls back to its built-in Lua sorter when fzf-native was skipped or never built
		pcall(require("telescope").load_extension, "fzf")
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep across the project (ripgrep)" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find open buffer" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help tag" })
	end,
}
