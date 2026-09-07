# windows/topics/

35 numbered `.ps1` files loaded in order by `../Microsoft.PowerShell_profile.ps1`. Each file covers one topic area. Add a new file with the next available number to extend the profile - it is picked up automatically at the next shell start.

## Topic files

| File | Topic | Key commands |
| --- | --- | --- |
| `01-path.ps1` | PATH and environment | Language runtime paths, `$env:PATH` adjustments |
| `02-colours.ps1` | Colour helper function | `Write-Colour` helper used by the welcome banner |
| `03-navigation.ps1` | Directory shortcuts | `dev`, `downloads` |
| `04-git.ps1` | Git aliases and helpers | `gs`, `ga`, `gaa`, `gcmt`, `gpsh`, `gcp`, `gpul` (note: `gc`/`gp`/`gl` reserved for `Get-Content`/`Get-ItemProperty`/`Get-Location`), `glog`, `gco`, `gcb`, `gb`, `gbd`, `gd`, `gundo`, `gclean`, `automerge`, `pull-all`, `repo-status` |
| `05-profile.ps1` | Profile management | `Edit-Profile`, `Reload-Profile` |
| `06-functions.ps1` | Core functions and command reference | `cmds`, `mkcd`, `mkf`, `mkr`, `mkt`, `dot` |
| `07-utilities.ps1` | General utilities | `ll`, `la`, `c`, `weather`, `temp`, `pubip`, `localip` |
| `08-community.ps1` | Community-borrowed utilities | `extract`, `dataurl`, `envup`, `digga`, `dns-flush`, `change-extension`, `clipcopy` (note: `copy` reserved for `Copy-Item`), `paste` |
| `09-cli-tools.ps1` | Modern CLI tools, text processing and process/port utilities | `z`, `zi` (zoxide), `ff`, `fcd`, `fh` (fzf), `ez`, `ezl`, `ezt` (eza), `rg2` (ripgrep, note: named `rg2` to avoid clashing with the `rg` binary itself), `col`, `replace`, `whatport`, `killport`, `notify` |
| `10-ssh.ps1` | SSH helpers | `keygen`, `sshcp`, `ssha`, `sshtest`, `sshfp`, `sshconf`, `sshls` |
| `11-network.ps1` | Network diagnostics | `myip`, `localip`, `ping4`, `portcheck`, `openports`, `portscan`, `headers` |
| `12-security.ps1` | SSL, GPG and crypto | `ssl-check`, `ssl-gen`, `ssl-view`, `gpgls`, `gpgenc`, `gpgdec`, `sha256file`, `sha512file` |
| `13-database.ps1` | Database shortcuts | `myconn`, `mydump`, `myls` (MySQL), `pgconn`, `pgdump`, `pgls` (Postgres), `rflush`, `rkeys` (Redis), `sqls` (SQLite) |
| `14-json.ps1` | JSON helpers | `json-check`, `json-min`, `json-keys`, `json-diff`, `jqk` |
| `15-rsync.ps1` | File sync - rsync via WSL and WinSCP | `rcopy`, `rmirror`, `rbackup`, `rdry` (rsync via WSL), `winscp-put`, `winscp-get`, `rclonecopy`, `rclonesync` |
| `16-winget.ps1` | winget and Chocolatey | `wgins`, `wgup`, `wgls`, `wgsearch`, `wginfo`, `wgrm`, `wgexport`, `wgimport` (winget), `chocoins`, `chocoup`, `chocolist`, `chocoinfo` (choco) |
| `17-gh.ps1` | GitHub CLI shortcuts | `ghpr`, `ghprc`, `ghclone`, `ghfork`, `ghissue`, `ghgist`, `ghrun`, `ghwatch`, `ghwho` |
| `18-nvm.ps1` | Node version manager | `nvminstall`, `nvmuse`, `nvmlts`, `nvmdefault`, `nvmls`, `nvmls-remote` (also fnm shortcuts) |
| `19-editors.ps1` | IDE and editor launchers | `code`, `idea`, `rider`, `phpstorm`, `datagrip`, `webstorm`, `goland`, `pycharm`, `clion` |
| `20-shell-tools.ps1` | Shell linting and formatting | `shck` (shellcheck - note: `sc` reserved for `sc.exe`), `psanalyse`, `psanalysefix`, `sfmt` |
| `21-tmux.ps1` | Windows Terminal and tmux via WSL | `wt-here`, `wt-split`, `tn`, `tls`, `tk`, `tka`, `cluster` |
| `22-docker.ps1` | Docker | `dps`, `drun2`, `dstop`, `drm`, `dimg`, `dprune`, `dlogs`, `dex`, `dcb`, `dcu`, `dcd`, `dcl`, `dcheck` |
| `23-kubernetes.ps1` | kubectl shortcuts | `kc` (kubectl), `kg`, `ka`, `kd`, `klogs`, `kns`, `kctx`, `kpods` |
| `24-cloud.ps1` | AWS, GCP and Azure | `awsls`, `awsp`, `awswho`, `awsec2`, `awslambda` (AWS), `gcls`, `gcwho` (GCP), `azls`, `azwho`, `azgroup` (Azure) |
| `25-devops.ps1` | Terraform and Ansible | `tfi`, `tfp`, `tfa`, `tfd`, `tfo`, `tfst`, `tfw` (Terraform), `ap`, `apcheck`, `aping`, `ard` (Ansible) |
| `26-python.ps1` | Python | `py`, `pip`, `venv`, `activate`, `ptest`, `pfmt`, `plint`, `djr`, `djm`, `djtest` |
| `27-web.ps1` | Node.js and npm | `npmi` (note: `ni` reserved for `New-Item`), `nr`, `nd`, `nb`, `ns`, `nt`, `nlint`, `nfmt`, `nout`, `naudit` |
| `28-ruby.ps1` | Ruby, Bundler, Rails | `be`, `binst`, `bupd`, `brewclean`/`brewoutd` (renamed to avoid clashing with Bundler's own `bclean`/`boutd`), `rs`, `rdm`, `rspec`, `rubocop` |
| `29-php.ps1` | PHP and Composer | `cupdate`, `creq`, `cdump`, `punit`, `pint`, `pserve` |
| `30-go.ps1` | Go toolchain | `gor`, `gob`, `got`, `gfmt`, `govet`, `gomod`, `goup` |
| `31-rust.ps1` | Cargo | `cr`, `cb`, `cbr`, `ct`, `ccheck`, `cfmt`, `cclippy` |
| `32-java.ps1` | Maven and Gradle wrapper | `mvnt`, `mvnb`, `mvni`, `mvnc`, `gwb`, `gwt`, `gwr` |
| `33-c-cpp.ps1` | GCC, Clang, LLDB, binary inspection | `cc2`, `ccrun`, `ccdbg`, `ccsan`, `cfmt2`, `ctidy`, `symbols` |
| `34-starship.ps1` | Starship prompt | Initialises the Starship cross-shell prompt (config in `windows/starship.toml`) |
| `35-secrets.ps1` | age and sops secrets encryption | `agenew`, `agenc`, `agedec`, `sopsenc`, `sopsdec`, `sopsedit`, `sopsview` |

## Adding a topic

Create a new file with the next available number, e.g. `36-mytopic.ps1`. It is picked up automatically. There is no need to edit the profile.

## Key Windows differences

- `sc` (shellcheck) is renamed to `shck` because `sc` is the Windows `sc.exe` Service Control Manager
- `copy`/`paste` use `Set-Clipboard`/`Get-Clipboard` instead of `pbcopy`/`xclip`
- `16-winget.ps1` replaces `16-brew.zsh` - covers winget and Chocolatey instead of Homebrew
- `21-tmux.ps1` adds `wt-here` and `wt-split` for Windows Terminal alongside WSL tmux shortcuts
