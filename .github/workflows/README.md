# Workflows

| Workflow | Runs on | What it does |
| --- | --- | --- |
| [`shellcheck.yml`](shellcheck.yml) | Push to `main`, every pull request | Lints `mac/` (zsh, `--shell=bash` compatibility mode) and `linux/` (bash) topic files and loaders. Windows PowerShell has no automated CI analysis, see [journal/006-windows-static-analysis.md](../../journal/006-windows-static-analysis.md) for why and how it's verified instead. |
| [`markdownlint.yml`](markdownlint.yml) | Push to `main`, every pull request | Lints every markdown file against [`.markdownlint.json`](../../.markdownlint.json) |

Both are also runnable manually via `workflow_dispatch` from the Actions tab.
