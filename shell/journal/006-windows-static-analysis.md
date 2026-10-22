# 006 - How the Windows PowerShell files were verified without pwsh

**Date:** June 2026
**Status:** Complete

---

## The problem

The 35 Windows topic files were written on a MacBook Air running macOS and zsh. PowerShell 7 (`pwsh`) is available on macOS via Homebrew, but it was not installed on this machine during the refactor session. That meant I could not do the obvious thing: `pwsh -NoProfile -Command "& { . ./file.ps1 }"` to actually parse and execute each file.

The question was: how do I verify 35 PowerShell files for syntax and naming correctness without a PowerShell interpreter?

---

## What was checked statically

### 1. Brace and bracket balance

PowerShell blocks use `{`, `}`, `(`, `)`, `[` and `]`. A missing closing brace is the most common syntax error in a PowerShell function. A quick balance check with `awk` counts opens and closes across each file:

```bash
for f in windows/topics/*.ps1; do
    opens=$(grep -o '{' "$f" | wc -l)
    closes=$(grep -o '}' "$f" | wc -l)
    if [[ $opens -ne $closes ]]; then
        echo "UNBALANCED: $f  opens=$opens closes=$closes"
    fi
done
```

All 35 files passed this check.

### 2. Bash-ism detection

Because the mac and linux topic files were written first, there was a risk of accidentally writing bash syntax in the PowerShell files (e.g. `local var=value`, `[[ condition ]]`, `$(command)` substitution in the wrong context, `alias name="..."` instead of `function name {}`). A grep pass checked for the most common bash-isms:

```bash
grep -rn 'alias ' windows/topics/
grep -rn '\[\[' windows/topics/
grep -rn 'local ' windows/topics/
grep -rn 'export ' windows/topics/
```

A few false positives came up (comments mentioning `alias` or `local` appearing in a path string) but no actual bash syntax was found in the PowerShell code.

### 3. Function name inventory

All function names were extracted and listed to check for duplicates within the windows set:

```bash
grep -h 'function ' windows/topics/*.ps1 | grep -v '#' | awk '{print $2}' | sort | uniq -d
```

No duplicates within the Windows topic files themselves.

### 4. Windows reserved name conflicts

A manual check was done against known Windows system binary names and PowerShell built-in aliases that are commonly used:

- `sc` - Service Control Manager (`sc.exe`) - found and renamed to `shck`
- `ni` - `New-Item` alias - found and renamed to `npmi`
- `sort` - PowerShell has its own `Sort-Object` with alias `sort` - no conflict because no topic file defines a `sort` function
- `curl` - Windows 10+ ships a native `curl.exe` - no conflict because `11-network.ps1` uses `Invoke-WebRequest` not a function named `curl`
- `where` - `where.exe` vs PowerShell's `Where-Object` alias - no conflict found
- `echo` - `echo` is an alias for `Write-Output` in PowerShell - found in `12-security.ps1` used to pipe an empty string to `openssl`. Replaced with `""` (see `002-alias-conflicts.md`)

### 5. Parameter block syntax

PowerShell functions use `param([type]$Name)` blocks. I checked that every function using parameters had a valid-looking `param(` line with matching `)`:

```bash
grep -A1 'function ' windows/topics/*.ps1 | grep -v 'param\|{' | head -20
```

This is a rough check, not a parser, but it caught any functions that had been given bash-style `$1` argument handling instead of PowerShell `param()`.

---

## What was not checked

Static analysis cannot catch:

- Runtime errors (e.g. a function calls `Get-ChildItem` with a flag that does not exist in the PowerShell version on the target machine)
- Version-specific syntax (backtick-e escape sequences like `` `e7 `` require PowerShell 7.2+; older versions need `[char]27 + "7"`)
- Cmdlet availability (e.g. `Invoke-ScriptAnalyzer` requires the `PSScriptAnalyzer` module)
- Encoding issues (PowerShell is sensitive to BOM on `.ps1` files in some versions)

The notes in each topic file comment block document the minimum PowerShell version and any module dependencies, so these are visible before running.

---

## Verification on first real Windows setup

The proper verification step happens when one of these profiles is installed on a Windows machine for the first time. The expected workflow is:

1. Open PowerShell 7.
2. Run `Reload-Profile` after installation.
3. Run `cmds` to confirm all sections printed correctly.
4. Spot-check a function from each topic area by running it with `--help` or no arguments to confirm it loads and responds.
5. Run `Invoke-ScriptAnalyzer -Path windows/topics/ -Recurse` (after installing PSScriptAnalyzer) to get a proper static analysis report.

The `20-shell-tools.ps1` file includes `psanalyse` and `psanalysefix` shortcuts specifically for this purpose.
