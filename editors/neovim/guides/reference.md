# Reference

## Key bindings

`+` means the keys are held together, for example `Ctrl+H` means hold Ctrl and press H. A space
between keys means press one after the other, for example `g d` means press `g` then `d`. The
leader key is Space, pressed and released on its own before the next key.

> [!NOTE]
> Capital and lowercase are genuinely different keys to Neovim, not a style choice. `<C-d>` is
> Ctrl held with a lowercase `d`. Holding Shift as well, `Ctrl+Shift+D`, is a different binding
> entirely and is not mapped here. Where a plain letter appears with no modifier (`gd`, `K`), the
> case matters on its own: `k` moves the cursor up, `K` opens LSP hover, two unrelated bindings
> that happen to share a letter.

| Mode | Keys | Action |
| --- | --- | --- |
| Insert | `j k` | Exit to normal mode |
| Normal | `Space w` | Save the file |
| Normal | `Space q` | Quit the window |
| Normal | `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` | Move to the split or tmux pane left/below/above/right (vim-tmux-navigator) |
| Normal | `Space e` | The file tree (snacks.nvim) |
| Normal | `Space g g` | lazygit inside Neovim (snacks.nvim) |
| Normal | `Space n` | Earlier messages (snacks.nvim) |
| Normal | `Space x x` / `Space x b` | Every error in the project / in this file (trouble.nvim) |
| Normal | `Space c f` | Format this file now, with the language server when no formatter is installed (conform.nvim) |
| Normal | `Ctrl+D` / `Ctrl+U` | Half-page down/up, cursor kept centred |
| Visual | `J` / `K` | Move the selected lines down/up |
| Normal | `g d` | Go to definition (LSP) |
| Normal | `g r` | List references (LSP) |
| Normal | `K` | Hover documentation (LSP), unrelated to visual mode's `K` above |
| Normal | `Space r n` | Rename symbol (LSP) |
| Normal | `Space c a` | Code action (LSP) |
| Normal | `[ d` / `] d` | Jump to the previous/next diagnostic |
| Normal | `Space f f` | Find files (Telescope) |
| Normal | `Space f g` | Live grep across the project (Telescope, via ripgrep) |
| Normal | `Space f b` | Find an open buffer (Telescope) |
| Normal | `Space f h` | Find a help tag (Telescope) |
| Insert | `Ctrl+Space` | Trigger completion |
| Insert | `Tab` / `Shift+Tab` | Next/previous completion item |
| Insert | `Enter` | Confirm the selected completion |

## Plugin manager

[`lazy.nvim`](https://github.com/folke/lazy.nvim), bootstrapped in `lua/config/lazy.lua`. Reads
every file under `lua/plugins/` automatically, so a new plugin means adding one file there, not
editing a central list.

## Plugins

| Plugin | What it does |
| --- | --- |
| `zacess.nvim` | The eight Zacess colour schemes, pinned to 0.6.0. `lua/config/theme.lua` picks one from the `zt` state file (`~/.local/state/zacess/theme`, `%LOCALAPPDATA%\zacess\theme` on Windows). With no state file it uses Zacess Deep Contrast Dark. It checks the file again on focus. `:ZacessFollow` returns to it after a manual `:colorscheme` |
| `colors/high-contrast.lua` | The earlier colour scheme (no plugin), kept for `:colorscheme high-contrast`: uses only the terminal's 16 colours |
| `nvim-treesitter` | Syntax highlighting and indentation, pinned to `master`, see below |
| `telescope.nvim` | Fuzzy finder, backed by `ripgrep` for grep and native fzf sort |
| `mason.nvim` / `mason-lspconfig.nvim` | Installs and manages LSP servers |
| `nvim-lspconfig` | Wires each server up via `vim.lsp.config`/`vim.lsp.enable`, the current native API (see below) |
| `nvim-cmp` | Autocompletion, LSP and snippet sources |
| `gitsigns.nvim` | Git status in the sign column, with one sign shape per kind of change (`+`, `~`, `_`, `‾`, `~_`, `┆`) and the line number coloured as well |
| `lualine.nvim` | Statusline, with a theme of the terminal's text colour and a reversed mode block |
| `which-key.nvim` | Shows the leader-key mappings as a popup |
| `vim-wakatime` | Sends coding time to WakaTime like the other editors, loaded at start-up. It reads the key from the WakaTime config file |
| `vim-tmux-navigator` | `Ctrl+H/J/K/L` across splits and tmux panes as one set, with its tmux half in the tmux config |
| `snacks.nvim` | A start screen, the file tree, lazygit inside Neovim, indent guides and a quieter message area. Its scrolling, dimming and animation parts are off and the indent guides never animate |
| `conform.nvim` | Formats a file on save with the language's own formatter when it is installed, a project's own (in `node_modules`) first. Language servers never format on save, since they can disagree with a project's formatter |
| `nvim-autopairs` | Adds the closing bracket or quote when the opening one is typed |
| `trouble.nvim` | Every error and warning in the project (or in one file) in one list |

## LSP servers (via Mason)

`clangd` (C and C++), `pyright` (Python), `typescript-language-server` (TypeScript and JavaScript, the
Mason package name for the `ts_ls` lspconfig server), `lua-language-server` (Mason package
name for the `lua_ls` lspconfig server, used for this config itself) and `marksman` (Markdown) on
every machine.

`lua/config/servers.lua` adds the servers that need a runtime only where that runtime is installed,
so Mason never fails to install one on every start: `rust_analyzer` with `cargo`, `gopls` with
`go`, `jdtls` (Java) with `java` and `html`, `cssls`, `jsonls` and `bashls` with `npm`.

## Design notes

- **Why `vim.lsp.config` and `vim.lsp.enable` instead of `require("lspconfig")[server].setup()`?**
  The old framework is deprecated as of Neovim 0.11 and removed in nvim-lspconfig v3. The native
  functions are the replacement.
- **Why is `nvim-treesitter` pinned to `master`?** Its default `main` branch is a rewrite that
  replaced the `nvim-treesitter.configs` module (the `highlight` and `indent` setup) with a
  different, more minimal API. `master` still carries the classic module `treesitter.lua` uses.
- **Why `ts_ls` and `lua_ls` as lspconfig names but different Mason package names?**
  `mason-lspconfig` translates between the two through its own `ensure_installed`. Running
  `:MasonInstall ts_ls` directly fails, since `ts_ls` is the lspconfig name and not the Mason
  registry name.
