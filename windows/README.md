# windows/

PowerShell profile for Windows. The entry point is `Microsoft.PowerShell_profile.ps1`, which acts as a loader - it dot-sources every numbered `.ps1` file in `topics/` in order. All functions and configuration live in those topic files, not in the profile itself.

## Files

| File | Purpose |
| --- | --- |
| `Microsoft.PowerShell_profile.ps1` | Loader: sets up colours and dot-sources all files in `topics/` in numerical order |

## Subfolders

| Folder | Contents |
| --- | --- |
| [`topics/`](topics/) | 35 numbered `.ps1` files, one topic per file |

## Installation

Open PowerShell and run:

```powershell
Copy-Item windows/Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

If the profile directory does not exist yet:

```powershell
New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force
Copy-Item windows/Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

After that, use `Edit-Profile` to open the profile in VS Code and `Reload-Profile` to apply changes without restarting. See [guides/windows.md](../guides/windows.md) for the full setup walkthrough and command reference.
