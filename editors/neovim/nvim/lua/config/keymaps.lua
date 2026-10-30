local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

-- Ctrl+H/J/K/L move between splits and tmux panes through vim-tmux-navigator, set up in
-- plugins/navigator.lua.

-- Keep the cursor centred while jumping half a page, easier to track on a low-vision setup.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Move a visual selection up or down instead of retyping it.
map("v", "J", ":m '>+1<cr>gv=gv")
map("v", "K", ":m '<-2<cr>gv=gv")
