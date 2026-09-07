# Development Workflow

Branch protection on `main` requires every change to go through a pull request
and pass the `Lint shell scripts` and `Lint markdown files` CI checks. Nothing
broken ever reaches main.

---

## Making a change

```bash
# 1. Always branch from the latest main
git checkout main && git pull
git checkout -b fix/your-description

# 2. Make your changes, then commit (conventional format)
git add <files>
git commit -m "fix: short description of what changed"

# 3. Push and open the PR, then enable auto-merge in one go
git push -u origin fix/your-description
gh pr create --title "fix: short description" --body "What changed and why."
gh pr merge --squash --delete-branch --auto

# 4. Wait ~1 minute for CI to pass - it merges and deletes the branch automatically.
```

Running `gh pr merge --auto` from your local terminal enables auto-merge as
yourself, not as a bot, so the resulting push to main triggers CI normally
and the commit gets a green tick.

---

## Commit message rules

- Use conventional prefixes: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full style rules

---

## Branch naming conventions

| Type | Example |
| ---- | ------- |
| New feature | `feat/add-rust-aliases` |
| Bug fix | `fix/nvm-lazy-load` |
| Chore / config | `chore/update-deps` |
| Documentation | `docs/journal-entry` |

---

## If CI fails

```bash
# Re-run from the Actions tab or push a fix commit to the same branch.
# If main moved ahead while your branch was open, rebase and re-enable auto-merge:
git fetch origin
git rebase origin/main
git push --force-with-lease
gh pr merge --squash --delete-branch --auto
```

---

## Checking PR status

```bash
gh pr list
gh pr view <number>
gh pr checks
```

---

## Dependabot

Dependabot opens PRs every Monday for outdated GitHub Actions versions. Review
and merge these the same way as any other PR, `gh pr merge --squash --delete-branch`
once CI passes, there is no automatic merge for them.
