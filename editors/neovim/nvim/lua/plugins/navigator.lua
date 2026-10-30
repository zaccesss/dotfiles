-- Ctrl+H/J/K/L move between Neovim splits and tmux panes as one set. The tmux half is the same
-- plugin loaded in tmux.conf; outside tmux the keys simply move between splits.
return {
	"christoomey/vim-tmux-navigator",
	cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
	keys = {
		{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to the split or pane on the left" },
		{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to the split or pane below" },
		{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to the split or pane above" },
		{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to the split or pane on the right" },
	},
}
