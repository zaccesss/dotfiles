# Documentation

Detailed technical reference for this dotfiles repo. This covers how the loader works, every command on every platform with full descriptions and how to extend the profile safely. For the quick-scan version, run `cmds` in the terminal.

---

## Contents

- [Architecture](#architecture)
- [Loader mechanics](#loader-mechanics)
- [Navigation](#navigation)
- [Git](#git)
- [Repo management](#repo-management)
- [Profile management](#profile-management)
- [Core functions](#core-functions)
- [Utilities](#utilities)
- [CLI tools](#cli-tools)
- [SSH](#ssh)
- [Network](#network)
- [Security and crypto](#security-and-crypto)
- [Database](#database)
- [JSON](#json)
- [File sync](#file-sync)
- [Package managers](#package-managers)
- [GitHub CLI](#github-cli)
- [Node version manager](#node-version-manager)
- [Editors and IDEs](#editors-and-ides)
- [Shell tools](#shell-tools)
- [tmux and Windows Terminal](#tmux-and-windows-terminal)
- [Docker](#docker)
- [Kubernetes](#kubernetes)
- [Cloud platforms](#cloud-platforms)
- [DevOps and infrastructure](#devops-and-infrastructure)
- [Starship prompt](#starship-prompt)
- [Secrets encryption](#secrets-encryption)
- [Extending the profile](#extending-the-profile)
- [Alias conflict rules](#alias-conflict-rules)

---

## Architecture

The profile is split across 35 numbered topic files rather than kept in a single monolithic profile. I did this because a single file past a few hundred lines becomes hard to navigate and topic files make it easy to find, add or remove a section without touching anything else.

```
dotfiles/
- mac/zshrc                 loader for macOS (zsh)
- mac/topics/01-path.zsh    first topic file
- mac/topics/02-colours.zsh second topic file
- ...
- mac/topics/34-starship.zsh   Starship prompt init
- mac/topics/35-secrets.zsh    age and sops encryption
- linux/bashrc              loader for Linux and WSL2 (bash)
- linux/topics/*.sh         same 35 topics, bash syntax
- windows/Microsoft.PowerShell_profile.ps1   loader for Windows (PowerShell)
- windows/topics/*.ps1      same 35 topics, PowerShell syntax
- mac/starship.toml         Starship prompt config for macOS
- linux/starship.toml       Starship prompt config for Linux and WSL2
- windows/starship.toml     Starship prompt config for Windows
```

---

## Loader mechanics

Each platform's loader file does two things: it sources `02-colours` (which defines ANSI colour variables used in the welcome banner and `cmds()`), then it sources every numbered topic file in order.

**Colour variables** (defined in `02-colours.{zsh,sh}` - Windows uses `-ForegroundColor` parameters directly):

| Variable | Code | Semantic use |
| --- | --- | --- |
| `RED` | `\033[0;31m` | Error messages |
| `GREEN` | `\033[0;32m` | Success messages, profile loaded |
| `YELLOW` | `\033[1;33m` | Warnings, date line in banner |
| `CYAN` | `\033[0;36m` | Progress/info, command names in `cmds()`, banner border |
| `MAGENTA` | `\033[0;35m` | Section headers in `cmds()` |
| `WHITE` | `\033[0;37m` | Descriptions in `cmds()`, parenthetical lines |
| `BOLD` | `\033[1m` | Bold weight |
| `RESET` | `\033[0m` | Clear all formatting |

**zsh (mac/zshrc):**
```zsh
for f in "$HOME/.config/zsh/topics"/[0-9]*.zsh; do
    [[ -r "$f" ]] && source "$f"
done
```

**bash (linux/bashrc):**
```bash
for f in "$HOME/.config/bash/topics"/[0-9]*.sh; do
    [[ -r "$f" ]] && source "$f"
done
```

**PowerShell (Microsoft.PowerShell_profile.ps1):**
```powershell
Get-ChildItem "$PSScriptRoot\topics\[0-9]*.ps1" | Sort-Object Name | ForEach-Object {
    . $_.FullName
}
```

Files are loaded in numerical order (01 before 02, etc.). A higher-numbered file can override an alias defined in a lower-numbered file. See [Alias conflict rules](#alias-conflict-rules) for the known intentional cases.

---

## Navigation

Quick directory shortcuts. All three platforms define the same command names.

| Command | Destination |
| --- | --- |
| `dev` | `~/dev` (macOS/Linux) or `C:\dev` (Windows) |
| `downloads` | `~/Downloads` |
| `dot` | dotfiles repo directory |

---

## Git

All git commands behave identically across platforms.

| Command | What it does |
| --- | --- |
| `gs` | `git status` |
| `ga <file>` | `git add <file>` |
| `gaa` | `git add --all` |
| `gcmt "message"` | `git commit -m "message"` |
| `gpsh` | `git push` |
| `gpul` | `git pull` |
| `glog` | Graph log: `git log --oneline --graph --decorate --all` |
| `gco <branch>` | `git checkout <branch>` |
| `gcb <branch>` | Create branch and switch to it: `git checkout -b <branch>` |
| `gb` | `git branch` - list local branches |
| `gbd <branch>` | Delete a local branch: `git branch -d <branch>` |
| `gd` | `git diff` |
| `gundo` | Undo last commit, keep changes staged: `git reset --soft HEAD~1` |
| `gclean` | Remove untracked files and directories: `git clean -fd` |
| `gcp "message"` | Stage all, commit and push in one step |
| `automerge` | Enable squash auto-merge on the current branch's PR and delete the branch after it lands: `gh pr merge --squash --delete-branch --auto` |
| `gfmt` | Format with gofmt (Go projects) |

---

## Repo management

| Command | What it does |
| --- | --- |
| `pull-all [dir]` | Pull the latest commits in every git repo under the given directory. Defaults to `~/dev/github/repos`. |
| `repo-status [dir]` | Show branch name and clean/dirty state for every repo under the given directory. |

---

## Profile management

| Command | What it does |
| --- | --- |
| `edit-profile` | Open the shell profile in VS Code |
| `reload-profile` | Re-source the profile without restarting the terminal |
| `dot` | `cd` to the dotfiles repo |

On macOS the profile lives at `~/.zshrc`. On Linux it is `~/.bashrc`. On Windows it is at `$PROFILE` (the path printed by `echo $PROFILE`).

---

## Core functions

These are defined in `06-functions` on all platforms.

| Command | What it does |
| --- | --- |
| `cmds` | Print all custom aliases and functions grouped by topic, piped through `less` (Windows: `Out-Host -Paging`), press q to exit. Output uses a 3-colour scheme: **MAGENTA (bold)** for section headers, **CYAN** for command names, **WHITE** for short descriptions. Parenthetical expansion lines (e.g. `(list / split / kill)`) are also WHITE. The legend line at the top explains the scheme. |
| `mkcd <dir>` | Create a directory and `cd` into it in one step. |
| `mkf <file>` | Create a file (and any missing parent directories) and open it in VS Code. |
| `mkr <name>` | Scaffold a new Rust project: `cargo new <name>` then open in VS Code. |
| `mkt <name>` | Scaffold a new TypeScript/Node project with `package.json` and `tsconfig.json`. |
| `dot` | Change to the dotfiles repo directory. |

---

## Utilities

| Command | Platform | What it does |
| --- | --- | --- |
| `ll` | All | Long list with hidden files and human-readable sizes |
| `la` | All | Long list with hidden files |
| `c` | All | Clear the terminal |
| `clipcopy` | macOS | Pipe to clipboard: wraps `pbcopy` |
| `clipcopy` | Linux | Pipe to clipboard: wraps `xclip -selection clipboard` |
| `clipcopy` | Windows | Set clipboard: `Set-Clipboard` |
| `paste` | macOS | Paste from clipboard: wraps `pbpaste` |
| `paste` | Linux | Paste from clipboard: wraps `xclip -selection clipboard -o` |
| `paste` | Windows | Get clipboard: `Get-Clipboard` |
| `pubip` | All | Print public IP address via `curl ifconfig.me` |
| `localip` | macOS | Print local network IP via `ipconfig getifaddr en0` |
| `localip` | Linux/Windows | Print local IP via `hostname -I` |
| `weather` | All | Print weather for current location via `wttr.in` |
| `temp` | All | Print temperature only via `wttr.in/?format="%t"` |

---

## CLI tools

Defined in `09-cli-tools` on all platforms. Additions alongside the real commands, not
replacements, `cat`/`ls`/`grep`/`cd` all keep working exactly as before. Requires fzf, zoxide,
bat, eza and ripgrep, install per platform: `brew install fzf zoxide bat eza ripgrep` (mac),
`sudo apt install fzf zoxide bat eza ripgrep` (linux),
`winget install fzf zoxide sharkdp.bat eza-community.eza BurntSushi.ripgrep.MSVC` (windows).
Every eval/init line is guarded with a `command -v`/`Get-Command` check, unlike Starship's own
unconditional line, since not everyone has these 5 tools installed yet.

| Command | What it does |
| --- | --- |
| `z <query>` | zoxide: jump to the best frecency match for `<query>` |
| `zi` | zoxide: interactive picker when more than one match is close |
| `ff` | fzf: fuzzy-find a file, open the pick in `$EDITOR` |
| `fcd` | fzf: fuzzy-find a directory, cd into the pick |
| `fh` | fzf: fuzzy-search shell history, run the pick |
| `ez` | eza: syntax-aware `ls` with icons and git status |
| `ezl` | eza: long listing, hidden files, git status (`-lah --git`) |
| `ezt` | eza: tree view, 2 levels deep |
| `rg2` | ripgrep. Named `rg2`, not `rg`, to avoid clashing with the `rg` binary name itself |
| `col <n>` | Extract column `<n>` from whitespace-separated piped text |
| `replace <old> <new> <file>` | In-place find-and-replace in a file |
| `whatport <port>` | Show what process is listening on a given port |
| `killport <port>` | Kill whatever process is listening on a given port |
| `notify <command>` | Run a command, send a system notification with its exit status when done |

---

## SSH

Defined in `10-ssh` on all platforms. Requires OpenSSH.

| Command | What it does |
| --- | --- |
| `keygen <name>` | Generate an ed25519 SSH key pair at `~/.ssh/<name>` with a comment |
| `sshcp <host>` | Copy the default public key to a remote host via `ssh-copy-id` |
| `ssha <host>` | Add the host to `~/.ssh/config` with a basic entry block |
| `sshtest <host>` | Test SSH connectivity to a host verbosely |
| `sshfp <host>` | Print the SSH fingerprint of a remote host |
| `sshconf` | Open `~/.ssh/config` in VS Code |
| `sshls` | List all hosts defined in `~/.ssh/config` |

---

## Network

Defined in `11-network` on all platforms.

| Command | What it does |
| --- | --- |
| `myip` | Print public IP address |
| `localip` | Print LAN IP address |
| `ping4` | Ping with IPv4 forced: `ping -4` |
| `portcheck <host> <port>` | Test whether a TCP port is open |
| `openports` | List all open listening ports on the current machine |
| `portscan <host>` | Run a quick nmap port scan |
| `headers <url>` | Print HTTP response headers via `curl -I` |

---

## Security and crypto

Defined in `12-security` on all platforms. Requires OpenSSL and GPG.

| Command | What it does |
| --- | --- |
| `ssl-check <host:port>` | Check the SSL certificate for a host - prints subject, issuer and expiry dates |
| `ssl-gen [name]` | Generate a self-signed certificate and key. Defaults to `localhost`. Outputs `<name>.crt` and `<name>.key`. |
| `ssl-view <file.crt>` | Print the full text of a certificate file |
| `sha256file <file>` | Print the SHA-256 hash of a file |
| `sha512file <file>` | Print the SHA-512 hash of a file |
| `md5file <file>` | Print the MD5 hash of a file |
| `gpgls` | List public GPG keys |
| `gpglss` | List secret GPG keys |
| `gpgenc <file> <recipient>` | Encrypt a file with armoured output |
| `gpgdec <file>` | Decrypt a GPG-encrypted file |
| `gpgsign <file>` | Create a detached armoured signature |
| `gpgverify <sig> <file>` | Verify a detached signature |
| `gpgexport <keyid>` | Export a public key in armoured format |
| `gpgimport <file>` | Import a key from a file |
| `wh <domain>` | Run `whois` on a domain |

---

## Database

Defined in `13-database` on all platforms.

**MySQL**

| Command | What it does |
| --- | --- |
| `myconn <db>` | Connect to a local MySQL database |
| `mydump <db>` | Dump a database to `<db>.sql` |
| `myls` | List all databases |

**PostgreSQL**

| Command | What it does |
| --- | --- |
| `pgconn <db>` | Connect via `psql` to a local database |
| `pgdump <db>` | Dump a database to `<db>.sql` |
| `pgls` | List all databases |
| `pgusers` | List all database users |

**Redis**

| Command | What it does |
| --- | --- |
| `rflush` | Flush all Redis keys |
| `rkeys` | List all keys |
| `rvals` | List all keys with their values |
| `rmon` | Open Redis monitor mode |
| `rping` | Ping Redis to check it is running |

**SQLite**

| Command | What it does |
| --- | --- |
| `sqls <file>` | Open a SQLite database file |
| `sqnew <file>` | Create a new SQLite database |
| `sqschema <file>` | Print the schema of a SQLite database |

---

## JSON

Defined in `14-json` on all platforms. Requires `jq`.

| Command | What it does |
| --- | --- |
| `json-check <file>` | Validate a JSON file - prints any parse errors |
| `json-min <file>` | Minify a JSON file |
| `json-keys <file>` | List all top-level keys |
| `json-diff <file1> <file2>` | Diff two JSON files |
| `jqk <key> <file>` | Extract a single key from a JSON file |

---

## File sync

Defined in `15-rsync` on all platforms. Requires `rsync` (and `rclone` for rclone commands).

| Command | What it does |
| --- | --- |
| `rcopy <src> <dst>` | Copy files with rsync, preserving permissions |
| `rmirror <src> <dst>` | Mirror a directory - deletes files in dst that are not in src |
| `rbackup <src> <dst>` | Backup with checksums |
| `rdry <src> <dst>` | Dry-run mirror - shows what would change without making changes |
| `rclonecopy <src> <dst>` | Copy between rclone remotes |
| `rclonesync <src> <dst>` | Sync between rclone remotes (bidirectional) |
| `rcloneremotes` | List all configured rclone remotes |

On Windows, rsync commands run through WSL. `winscp-put` and `winscp-get` are available as Windows-native alternatives.

---

## Package managers

### Homebrew (macOS and Linux)

Defined in `16-brew`. Note: `binsc` (cask install) is macOS only. Linuxbrew does not support casks.

| Command | What it does |
| --- | --- |
| `bup` | `brew update && brew upgrade && brew cleanup` - my weekly maintenance command |
| `bls` | List all installed formulae |
| `blsc` | List installed casks (macOS only) |
| `bsearch <term>` | Search for a formula or cask |
| `bins <formula>` | Install a formula |
| `binsc <cask>` | Install a cask (macOS only) |
| `brm <formula>` | Uninstall a formula |
| `binfo <formula>` | Show version, dependencies and options |
| `bdeps <formula>` | Show the dependency tree |
| `bdr` | Run `brew doctor` to check for problems |
| `bleave` | Remove unused dependencies: `brew autoremove` |
| `brewclean` | Remove old formula versions: `brew cleanup` |
| `brewoutd` | List formulae with available updates |
| `bpin <formula>` | Pin a formula to prevent upgrades |
| `bunpin <formula>` | Unpin a formula |

### winget and Chocolatey (Windows)

Defined in `16-winget.ps1`.

| Command | What it does |
| --- | --- |
| `wgins <id>` | `winget install <id>` |
| `wgup` | `winget upgrade --all` |
| `wgls` | List installed packages |
| `wgsearch <term>` | Search winget |
| `wginfo <id>` | Show package details |
| `wgrm <id>` | Uninstall a package |
| `wgexport` | Export the installed package list to JSON |
| `wgimport <file>` | Install packages from an exported JSON file |
| `chocoins <pkg>` | `choco install <pkg> -y` |
| `chocoup` | `choco upgrade all -y` |
| `chocolist` | List installed choco packages |
| `chocoinfo <pkg>` | Show choco package details |

---

## GitHub CLI

Defined in `17-gh` on all platforms. Requires `gh`.

| Command | What it does |
| --- | --- |
| `ghpr <title> [body]` | Create a PR from the current branch with a title and body |
| `ghprl` | List open PRs |
| `ghprv <number>` | Open a PR in the browser |
| `ghprc` | Create a PR interactively |
| `ghprs` | Show PRs relevant to you |
| `ghprm <number>` | Squash-merge a PR and delete its branch |
| `ghprco <number>` | Check out a PR locally |
| `ghprcomment <number> <body>` | Comment on a PR |
| `ghprclose <number>` | Close a PR |
| `ghprreopen <number>` | Reopen a PR |
| `ghprdiff <number>` | Show a PR's diff |
| `ghprready <number>` | Mark a draft PR as ready for review |
| `ghprupdate <number>` | Update a PR's branch from its base |
| `ghprchecks <number>` | Show a PR's CI check status |
| `ghprmine` | List PRs assigned to you in the current repo |
| `ghissl` | List open issues |
| `ghissv <number>` | View an issue |
| `ghissc <title>` | Create an issue |
| `ghissclose <number>` | Close an issue |
| `ghissreopen <number>` | Reopen an issue |
| `ghisspin <number>` | Pin an issue |
| `ghissunpin <number>` | Unpin an issue |
| `ghisscomment <number> <body>` | Comment on an issue |
| `ghmine` | List issues assigned to you in the current repo |
| `ghrun` | List recent workflow runs |
| `ghwatch <run-id>` | Watch a running workflow |
| `ghfail` | List failed workflow runs |
| `ghrls` | List releases |
| `ghrlsc` | Create a release |
| `ghrepo` | Open the current repo in the browser |
| `ghfork <repo>` | Fork a repo |
| `ghclone <repo>` | Clone a repo |
| `ghsync` | Sync a fork with its upstream |
| `ghwiki <owner/repo>` | Clone a repo's wiki, its own separate git repo, `gh` has no native wiki command |
| `ghgist` | List your gists |
| `ghgistc <file>` | Create a gist from a file |
| `ghwho` | Print the authenticated GitHub user |
| `ghlabels` | List a repo's labels |
| `ghaddlabel <number> <label>` | Add a label to a PR or issue, tries PR first then falls back to issue |
| `ghautomerge <number>` | Add the `automerge` label, arms native squash auto-merge |
| `ghautoclose <number>` | Add the `autoclose` label, closes the linked issue on merge |
| `ghclosenow <number>` | Add the `close-now` label, closes an issue immediately, bulk triage |
| `ghreview <number> <body>` | Review with a comment, safe on your own repos where self-approval is blocked anyway |
| `ghapprove <number> [body]` | Approve, only for someone else's repo or a fork, never your own |
| `ghrules` | List branch protection rulesets for the current repo |
| `ghstart <title> <label> <branch>` | Create an issue, check out `main`, pull, branch, the full issue-to-branch ritual in one step |
| `ghprojls` | List projects (v2) |
| `ghprojview <number>` | View a project |
| `ghprojadd <project> <item>` | Add an item to a project |

GitHub Discussions has no native `gh` command (confirmed: `gh discussion` errors as an unknown
command), only reachable via `gh api graphql`, not worth a thin wrapper alias for.

---

## Node version manager

Defined in `18-nvm` on all platforms. On macOS and Linux, nvm is lazy-loaded to avoid the ~200ms startup penalty it causes when sourced unconditionally. The first call to any nvm command loads it transparently.

| Command | What it does |
| --- | --- |
| `nvminstall <version>` | Install a Node version: `nvm install <version>` |
| `nvmuse <version>` | Switch Node version for the current session: `nvm use <version>` |
| `nvmlts` | Install and use the latest LTS release |
| `nvmdefault <version>` | Set the default Node version |
| `nvmls` | List installed Node versions |
| `nvmls-remote` | List all available remote versions |

---

## Editors and IDEs

Defined in `19-editors` on all platforms. All commands open the current directory or a specified path.

| Command | Editor/IDE |
| --- | --- |
| `code [path]` | VS Code |
| `idea [path]` | IntelliJ IDEA |
| `rider [path]` | JetBrains Rider |
| `phpstorm [path]` | PhpStorm |
| `datagrip [path]` | DataGrip |
| `webstorm [path]` | WebStorm |
| `goland [path]` | GoLand |
| `pycharm [path]` | PyCharm |
| `clion [path]` | CLion |

---

## Shell tools

Defined in `20-shell-tools` on all platforms.

| Command | Platform | What it does |
| --- | --- | --- |
| `sc [file]` | macOS / Linux | Run shellcheck on a `.sh` file or check all `.sh` files recursively if no argument given |
| `shck [file]` | Windows | Same as `sc` - renamed because `sc` is Windows' `sc.exe` Service Control Manager |
| `sfmt <file>` | All | Format a shell script with shfmt |
| `sfmtcheck <file>` | macOS / Linux | Check formatting without writing |
| `sfmtdiff <file>` | macOS / Linux | Show formatting diff |
| `psanalyse [path]` | Windows | Run PSScriptAnalyzer on a `.ps1` file or directory |
| `psanalysefix <file>` | Windows | Auto-fix PSScriptAnalyzer warnings |

---

## tmux and Windows Terminal

Defined in `21-tmux` on all platforms.

| Command | Platform | What it does |
| --- | --- | --- |
| `tn <name>` | macOS / Linux | Create a new named tmux session |
| `tls` | macOS / Linux | List tmux sessions |
| `tk <name>` | macOS / Linux | Kill a named tmux session |
| `tka` | macOS / Linux | Kill all tmux sessions |
| `cluster` | macOS / Linux | Open a 4-pane tmux cluster layout |
| `wt-here` | Windows | Open a new Windows Terminal tab in the current directory |
| `wt-split` | Windows | Split the current Windows Terminal pane |

---

## Docker

Defined in `22-docker` on all platforms. Requires Docker Desktop (or Docker Engine on Linux).

| Command | What it does |
| --- | --- |
| `dps` | `docker ps` - list running containers |
| `drun2 <image>` | Run a container interactively: `docker run -it --rm <image>` |
| `dstop <id>` | Stop a container |
| `drm <id>` | Remove a stopped container |
| `dimg` | List images |
| `dprune` | Remove all stopped containers, unused networks and dangling images |
| `dlogs <id>` | Tail logs for a container |
| `dex <id> <cmd>` | Exec a command in a running container |
| `dcb` | `docker-compose build` |
| `dcu` | `docker-compose up -d` |
| `dcud` | `docker-compose up -d --build` |
| `dcd` | `docker-compose down` |
| `dcl` | `docker-compose logs -f` |
| `dcheck` | `docker-compose config` - validate the compose file |
| `dinfo` | `docker info` |
| `dpa` | `docker system prune -a` - remove everything unused |

---

## Kubernetes

Defined in `23-kubernetes` on all platforms. Requires `kubectl`.

| Command | What it does |
| --- | --- |
| `kc` | `kubectl` - the main shortcut |
| `kg <resource>` | `kubectl get <resource>` |
| `ka <file>` | `kubectl apply -f <file>` |
| `kd <resource>` | `kubectl describe <resource>` |
| `klogs <pod>` | `kubectl logs -f <pod>` - tail logs |
| `kns <namespace>` | `kubectl config set-context --current --namespace=<namespace>` |
| `kctx` | `kubectl config get-contexts` - list contexts |
| `kpods` | `kubectl get pods --all-namespaces` |

---

## Cloud platforms

Defined in `24-cloud` on all platforms.

**AWS** (requires `aws` CLI)

| Command | What it does |
| --- | --- |
| `awsls` | List S3 buckets |
| `awsp <profile>` | Switch AWS profile |
| `awswho` | Print current identity: `aws sts get-caller-identity` |
| `awsregion <region>` | Set default region |
| `awsec2` | List EC2 instances |
| `awslambda` | List Lambda functions |
| `awslogs <group>` | Tail a CloudWatch log group |

**GCP** (requires `gcloud`)

| Command | What it does |
| --- | --- |
| `gcls` | List GCP projects |
| `gccfg` | Show active config |
| `gcwho` | Print active account |
| `gcvms` | List Compute Engine instances |
| `gcrun` | List Cloud Run services |

**Azure** (requires `az`)

| Command | What it does |
| --- | --- |
| `azls` | List resource groups |
| `azwho` | Print logged-in account |
| `azgroup` | List resource groups |
| `azsub` | List subscriptions |
| `azvm` | List VMs |
| `azweb` | List web apps |
| `azlogs` | Tail Activity Log |

---

## DevOps and infrastructure

Defined in `25-devops` on all platforms.

**Terraform** (requires `terraform`)

| Command | What it does |
| --- | --- |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` |
| `tfaa` | `terraform apply --auto-approve` |
| `tfd` | `terraform destroy` |
| `tfda` | `terraform destroy --auto-approve` |
| `tfo` | `terraform output` |
| `tfst` | `terraform state list` |
| `tfs` | `terraform show` |
| `tfv` | `terraform validate` |
| `tff` | `terraform fmt` |
| `tfw` | `terraform workspace list` |
| `tfwn <name>` | `terraform workspace new <name>` |
| `tfwsel <name>` | `terraform workspace select <name>` |

**Ansible** (requires `ansible`)

| Command | What it does |
| --- | --- |
| `ap <playbook>` | `ansible-playbook <playbook>` |
| `apcheck <playbook>` | Dry-run check: `ansible-playbook --check` |
| `aping <host>` | Ping an Ansible host |
| `ard` | `ansible-doc` |

---

## Python

Defined in `26-python` on all platforms.

| Command | What it does |
| --- | --- |
| `py` | `python3` |
| `pip` | `pip3` |
| `venv` | `python3 -m venv venv` |
| `activate` | `source venv/bin/activate` |
| `ptest` | `pytest` |
| `ptestcov` | `pytest --cov` |
| `plint` | `ruff check .` |
| `pfmt` | `ruff format .` |
| `ptype` | `mypy .` |
| `preqs` | `pip install -r requirements.txt` |
| `pfreeze` | `pip freeze > requirements.txt` |
| `ipy` | `ipython` |
| `djr` | `python manage.py runserver` |
| `djm` | `python manage.py migrate` |
| `djmm` | `python manage.py makemigrations` |
| `djs` | `python manage.py shell` |
| `djc` | `python manage.py collectstatic --noinput` |
| `djsu` | `python manage.py createsuperuser` |
| `djtest` | `python manage.py test` |

---

## Web and Node

Defined in `27-web` on all platforms. All aliases use the `n` prefix so they do not
clash with system commands.

| Command | What it does |
| --- | --- |
| `ni` | `npm install` (macOS/Linux) |
| `npmi` | `npm install` (Windows, `ni` is reserved for `New-Item`) |
| `nid` | `npm install --save-dev` |
| `nr` | `npm run` |
| `nd` | `npm run dev` |
| `nb` | `npm run build` |
| `ns` | `npm start` |
| `nt` | `npm test` |
| `ntw` | `npm test -- --watch` |
| `nlint` | `npm run lint` |
| `nfmt` | `npm run format` |
| `nview` | `npm view` |
| `nls` | `npm ls` |
| `nglobal` | `npm ls -g --depth=0` |
| `nci` | `npm ci` |
| `nout` | `npm outdated` |
| `naudit` | `npm audit` |
| `nauditfix` | `npm audit fix` |
| `ntc` | `npm run typecheck` |
| `tsw` | `tsc --watch` |
| `nreset` | Delete `node_modules` and the lockfile, then reinstall |

---

## Ruby

Defined in `28-ruby` on all platforms. Requires `rbenv` and `ruby-build`.

| Command | What it does |
| --- | --- |
| `rbls` | `rbenv versions` |
| `rbuse` | `rbenv local` |
| `rbglobal` | `rbenv global` |
| `rbinstall` | `rbenv install` |
| `be` | `bundle exec` |
| `binst` | `bundle install` |
| `bupd` | `bundle update` |
| `boutd` | `bundle outdated` |
| `bcheck` | `bundle check` |
| `bclean` | `bundle clean --force` |
| `rs` | `bundle exec rails server` |
| `rc` | `bundle exec rails console` |
| `rg` | `bundle exec rails generate` |
| `rgm` | `bundle exec rails generate model` |
| `rgc` | `bundle exec rails generate controller` |
| `rds` | `bundle exec rails db:seed` |
| `rdc` | `bundle exec rails db:create` |
| `rdd` | `bundle exec rails db:drop` |
| `rdreset` | `bundle exec rails db:reset` |
| `rdm` | `bundle exec rails db:migrate` |
| `rrout` | `bundle exec rails routes` |
| `rtask` | `bundle exec rails` |
| `rnew` | `rails new` (run outside `bundle exec`, no Gemfile yet) |
| `rspec` | `bundle exec rspec` |
| `rspecf` | `bundle exec rspec --format documentation` |
| `rb` | `ruby` |
| `irb` | `bundle exec irb`, falls back to plain `irb` |
| `gemi` | `gem install` |
| `gemls` | `gem list` |
| `rubocop` | `bundle exec rubocop`, falls back to plain `rubocop` |
| `rubofix` | `bundle exec rubocop --autocorrect` |

**Homebrew's own `bclean`/`boutd`** are renamed `brewclean`/`brewoutd` in `16-brew` to avoid
clashing with these Bundler commands. See [journal/003-alias-conflicts.md](../journal/003-alias-conflicts.md).

---

## PHP

Defined in `29-php` on all platforms. Laravel aliases use the `pa` prefix (`php artisan`).

| Command | What it does |
| --- | --- |
| `pa` | `php artisan` |
| `par` | `php artisan serve` |
| `pamm` | `php artisan make:migration` |
| `pamc` | `php artisan make:controller` |
| `pam` | `php artisan migrate` |
| `pamr` | `php artisan migrate:rollback` |
| `pamfs` | `php artisan migrate:fresh --seed` |
| `pads` | `php artisan db:seed` |
| `parl` | `php artisan route:list` |
| `paq` | `php artisan queue:work` |
| `paoc` | `php artisan optimize:clear` |
| `pat` | `php artisan tinker` |
| `pserve` | `php -S localhost:8000` (no framework) |
| `ci` | `composer install` |
| `cupdate` | `composer update` |
| `creq` | `composer require` |
| `cdump` | `composer dump-autoload` |
| `coutdated` | `composer outdated` |
| `punit` | `./vendor/bin/phpunit` |
| `pint` | `./vendor/bin/pint` |

---

## Go

Defined in `30-go` on all platforms.

| Command | What it does |
| --- | --- |
| `gor` | `go run .` |
| `gob` | `go build ./...` |
| `got` | `go test ./...` |
| `gfmt` | `go fmt ./...` |
| `govet` | `go vet ./...` |
| `gomod` | `go mod tidy` |
| `goi` | `go install ./...` |
| `goup` | `go get -u ./...` |
| `godoc` | `go doc` |
| `gocov` | `go test -cover ./...` |
| `goenv` | `go env` |
| `goci` | `golangci-lint run` (requires `golangci-lint`) |
| `goadd <pkg>` | `go get <pkg>` |

---

## Rust

Defined in `31-rust` on all platforms. Requires `cargo`.

| Command | What it does |
| --- | --- |
| `cr` | `cargo run` |
| `cb` | `cargo build` |
| `cbr` | `cargo build --release` |
| `ct` | `cargo test` |
| `ccheck` | `cargo check` |
| `cfmt` | `cargo fmt` |
| `cclean` | `cargo clean` |
| `cinit` | `cargo init` |
| `cadd` | `cargo add` |
| `crm` | `cargo remove` |
| `cupd` | `cargo update` |
| `cdoc` | `cargo doc --open` |
| `cbench` | `cargo bench` |
| `cclippy` | `cargo clippy` |

---

## Java

Defined in `32-java` on all platforms. Gradle aliases use the wrapper script (`./gradlew`).

**Maven**

| Command | What it does |
| --- | --- |
| `mvnt` | `mvn test` |
| `mvnb` | `mvn package` |
| `mvni` | `mvn install` |
| `mvnc` | `mvn clean` |
| `mvncb` | `mvn clean package` |
| `mvndep` | `mvn dependency:tree` |
| `mvnskip` | `mvn install -DskipTests` |

**Gradle**

| Command | What it does |
| --- | --- |
| `gwb` | `./gradlew build` |
| `gwt` | `./gradlew test` |
| `gwr` | `./gradlew run` |
| `gwc` | `./gradlew clean` |
| `gwcb` | `./gradlew clean build` |
| `gwdep` | `./gradlew dependencies` |
| `gwtasks` | `./gradlew tasks` |

---

## C and C++

Defined in `33-c-cpp` on all platforms. Requires `clang` (from Xcode on macOS, or
`brew install gcc`/a Linux toolchain elsewhere).

| Command | What it does |
| --- | --- |
| `cc2 <file>` | Compile a C file (avoids shadowing the system `cc`) |
| `ccrun <file>` | Compile, run, then remove the binary |
| `ccdbg <file>` | Compile a C file with debug symbols |
| `ccsan <file>` | Compile a C file with address/undefined-behaviour sanitizers |
| `cppc <file>` | Compile a `.cpp` file (C++20) |
| `cpprun <file>` | Compile, run, then remove the binary |
| `cppdbg <file>` | Compile C++ with debug symbols |
| `cppsan <file>` | Compile C++ with sanitizers |
| `dbg` | `lldb` |
| `cfmt2` | `clang-format -i` |
| `ctidy` | `clang-tidy` |
| `symbols` | `nm -gU` |
| `odump` | `objdump` |
| `hd` | `hexdump -C` |
| `bsize` | `size` |

---

## Starship prompt

Defined in `34-starship` on all platforms. Config in each platform's own `starship.toml`
(`mac/starship.toml`, `linux/starship.toml`, `windows/starship.toml`), identical content on all
three, kept in sync by hand rather than a single shared file.

Starship replaces the shell's default prompt line (`%` / `$`) with a dynamic one that
re-evaluates on every Enter press. Only modules relevant to the current directory appear -
git info only shows inside git repos, language versions only inside matching projects.

### Layout

An explicit `format` (Starship's own default order, confirmed against its docs) covers line 1
and the start of line 2, `right_format = "$time"` puts the clock on the right edge of line 1
instead of sharing line 2 with the prompt character, so a plain prompt with nothing to report
is a single line. Hostname already sits before directory in Starship's real default order, an
SSH session reads "machine, then folder" without needing any reordering.

### Colour theme

Uses Starship's own named ANSI colours (`bold green`/`cyan`/`yellow`/`red`/`blue`/`purple`/
`orange`, plus `bright-` variants), not fixed hex values, so every colour renders using the
terminal's own theme, matching the welcome banner exactly, since the banner also prints plain
ANSI escape codes directly (`02-colours.zsh`). A fixed hex palette looked visually inconsistent
with the banner in practice, this approach can't, both draw from the same terminal-defined
colours. Every navigational module (directory, git branch, git status, hostname, jobs, command
duration, battery, time) gets a colour distinct from every other navigational module that could
share a line with it, using a `bright-` variant once the base 8 colours run out. Language
modules reuse colours more freely since at most one renders at a time in practice, picked to
match each language's real brand identity as closely as the base ANSI palette allows. Kotlin,
Scala, R (`rlang`), Kubernetes, Helm and Maven each get Starship's own native module, not
lumped under a generic Java/language catch-all.

| What you see | Colour | When it appears |
| --- | --- | --- |
| Directory (3 segments) | blue | Always |
| Branch | cyan | Inside any git repo |
| Git status | yellow | Uncommitted changes, ahead/behind, conflicts |
| Hostname | purple | Over SSH only, e.g. onto the `10-ssh` cluster nodes |
| Kubernetes context | bright blue | A kube config is active, real safety net against the wrong cluster |
| Jobs | bright cyan | 2 or more background/suspended jobs |
| Python version | yellow, Python's own brand includes yellow | `.py` file, `pyproject.toml`, `requirements.txt` or `.python-version` present |
| Node version | green, Node's own brand | `package.json` present |
| Go version | cyan, the gopher's own brand leans cyan-blue | `go.mod` or `.go` files present |
| Rust version | orange, the Rust Foundation's own brand | `Cargo.toml` or `.rs` files present |
| Java version | red, closest to Java's own orange-red brand | `.java` files present |
| Kotlin version | purple, Kotlin's own brand | `.kt` or `.kts` files present |
| Scala version | red, Scala's own brand | `.scala` files present |
| Maven | red | `pom.xml` present |
| PHP version | purple, closest to PHP's own blue-purple brand | `.php` files present |
| Ruby version | red, Ruby's own brand | `.rb` files or `Gemfile` present |
| R version | blue, R's own community colour | `.R`, `.Rmd`, `.Rproj` files, `.Rprofile` or an `renv` folder present |
| .NET version | purple, .NET's own brand | `.cs`, `.csproj` or `.fsproj` files present |
| Docker context | blue, Docker's own brand | `Dockerfile` or `docker-compose.yml` present |
| Helm | bright blue, same as Kubernetes, closely related tools | `Chart.yaml` or `helmfile.yaml` present |
| Lua version | blue, closest to Lua's own navy brand | `.lua` files present |
| Zig version | yellow, closest to Zig's own gold brand | `.zig` files present |
| Swift version | orange, Swift's own brand, from swift.org | `.swift` files present |
| Elixir version | purple, Elixir's own brand | `.ex`, `.exs` or `mix.exs` present |
| Haskell version | purple, Haskell's own brand | `stack.yaml`, `.cabal` or `.hs` files present |
| Deno version | green, closest to Deno's own mint brand | `deno.json`, `deno.jsonc` or `deno.lock` present |
| Bun version | yellow, closest to Bun's own pale gold brand | `bun.lockb` present |
| Dart/Flutter version | blue, Dart's own brand | `pubspec.yaml` present |
| C/C++ | blue | `.c`, `.cpp`, `.h` or `.hpp` files present |
| Command duration | bright red | Any command that took longer than 2 seconds |
| Battery | bright red / yellow | Discharging, below 10% / 10-30%, hidden above 30% |
| Time | white, kept off yellow deliberately since yellow means "warning" everywhere else in this theme | Always, right edge of line 1, redraws with every prompt |
| Prompt character | green / bright red | Green on success, red on the last command's non-zero exit |

To disable Starship entirely: comment out the `eval` line in `34-starship.zsh` (or `.sh` / `.ps1`) and reload.
To hide a specific module: add `disabled = true` under its section in that platform's `starship.toml`.

Each platform keeps its own copy of `starship.toml`, not one shared file, so a config change made
on one device needs applying to the other two platform copies by hand (or via `git pull` once
committed) to stay in step.

---

## Secrets encryption

Defined in `35-secrets` on all platforms. For committing a secret to git safely, encrypted,
rather than the `chmod 600` unencrypted-file approach `NOTICE.md` otherwise recommends. Uses
age for whole-file encryption and sops for in-place encryption of individual values inside a
structured file (YAML, JSON, `.env`).

| Command | What it does |
| --- | --- |
| `agenew` | Generate a new age keypair at `~/.config/age/keys.txt` |
| `agenc <file> <recipient>` | Encrypt a file to `<file>.age` for a recipient's public key |
| `agedec <file.age>` | Decrypt a `.age` file back to its original name |
| `sopsenc <file>` | Encrypt a file in place with sops |
| `sopsdec <file>` | Decrypt a file in place with sops |
| `sopsedit <file>` | Open an encrypted file in `$EDITOR`, decrypted while editing, re-encrypted on save |
| `sopsview <file>` | Print a decrypted file to stdout without writing anything to disk |

---

## Extending the profile

To add a new group of aliases:

1. Create a new file in the relevant `topics/` folder with the next available number, e.g. `36-mytopic.zsh` (macOS), `36-mytopic.sh` (Linux) or `36-mytopic.ps1` (Windows). (`34` is taken by Starship, `35` by secrets encryption.)
2. Add your aliases and functions to the file.
3. Reload the profile: `reload-profile`.
4. Run `cmds` to verify the new commands appear. If you want them listed there too, add a section to `06-functions` under `cmds()`.

There is no need to edit the loader file (`zshrc`, `bashrc` or the PowerShell profile). The glob pattern picks up any file matching `[0-9]*.{zsh,sh,ps1}` automatically.

To remove a command, delete or comment out the line in its topic file and reload. Do not leave commented stubs - delete the line entirely.

---

## Alias conflict rules

Files are sourced in numerical order. A higher-numbered file can override an alias defined in a lower-numbered file. Known intentional cases:

| Name | Conflict | Resolution |
| --- | --- | --- |
| `sc` | shellcheck (20-shell-tools) vs `sc.exe`, the Windows Service Control Manager | Renamed to `shck` on Windows only |
| `echo` | PowerShell's `echo` wraps a string in an object before piping, breaking `openssl` in `11-security.ps1` | Replaced with a bare string literal in the pipe |

When adding new aliases, check for conflicts with: (a) earlier topic files, (b) shell built-ins, (c) platform-specific reserved names like `ni` (New-Item) and `sc` (Service Control) on Windows.
