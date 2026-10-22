# Extending

Each hook file has a section near the bottom marked `# --- Extension point`. That is where a
new check goes.

## Adding a check

Follow the same shape every existing check uses:

```sh
# --- N. Your check name ---------------------------------------------------
your_check_hit=0

if some_condition; then
    echo "Error: describe what is wrong and why."
    your_check_hit=1
fi

if [ "$your_check_hit" -eq 1 ]; then
    echo "Fix the problem, or use '--no-verify' if this is a false positive."
    exit 1
fi
```

A few things worth keeping:

- Print a clear `Error: ...` line explaining what is wrong, not just that something failed.
- Let every check in the file run before exiting, rather than stopping at the first failure,
  so one commit attempt reports every problem at once.
- If a fix is safe to apply automatically (a pure text substitution with no ambiguity), fix it
  and re-check afterwards that the fix actually worked, rather than fixing once and hoping.
- Remember to make the same change in all three platform folders (`mac/`, `linux/`,
  `windows/`) if the check does not depend on OS-specific tooling.

## Examples of what could go here

- A content-style rule (banned words or characters, a required tone).
- A required commit type prefix, for a repo following conventional commits strictly.
- A licence-header check on new source files.
- A naming convention for branches or files.
- A project-specific credential shape not already covered by the generic secret patterns in
  `pre-commit`.

## Keeping future updates easy to merge

If you want to pull in future updates to the checks in this folder without losing your own
additions, keep your extension in its own clearly marked block rather than interleaving it
with the existing checks. That makes a future `git pull` and re-merge far easier to reason
about.
