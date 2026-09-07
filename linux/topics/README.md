# linux/topics/

35 numbered `.sh` files loaded in order by `../bashrc`. Each file covers one topic area. Add a new file with the next available number to extend the profile - it is picked up automatically at the next shell start.

## Topic files

| File | Topic | Key commands |
| --- | --- | --- |
| `01-path.sh` | PATH and environment | Linuxbrew, `~/bin`, language runtime paths |
| `02-colours.sh` | Terminal colour variables | `BOLD`, `DIM`, `RESET`, `RED`, `GREEN`, `YELLOW`, `CYAN`, `BLUE` |
| `03-navigation.sh` | Directory shortcuts | `dev`, `downloads` |
| `04-git.sh` | Git aliases and helpers | `gs`, `ga`, `gaa`, `gcmt`, `gpsh`, `gcp`, `gpul`, `glog`, `gco`, `gcb`, `gb`, `gbd`, `gd`, `gundo`, `gclean`, `automerge`, `pull-all`, `repo-status` |
| `05-profile.sh` | Profile management | `edit-profile`, `reload-profile` |
| `06-functions.sh` | Core functions and command reference | `cmds`, `mkcd`, `mkf`, `mkr`, `mkt`, `dot` |
| `07-utilities.sh` | General utilities | `ll`, `la`, `c`, `weather`, `temp`, `pubip`, `localip` |
| `08-community.sh` | Community-borrowed utilities | `extract`, `dataurl`, `envup`, `digga`, `dns-flush`, `change-extension`, `clipcopy`, `paste` |
| `09-cli-tools.sh` | Modern CLI tools, text processing and process/port utilities | `z`, `zi` (zoxide), `ff`, `fcd`, `fh` (fzf), `ez`, `ezl`, `ezt` (eza), `rg2` (ripgrep), `col`, `replace`, `whatport`, `killport`, `notify` |
| `10-ssh.sh` | SSH helpers | `keygen`, `sshcp`, `ssha`, `sshtest`, `sshfp`, `sshconf`, `sshls` |
| `11-network.sh` | Network diagnostics | `myip`, `localip`, `ping4`, `portcheck`, `openports`, `portscan`, `headers` |
| `12-security.sh` | SSL, GPG and crypto | `ssl-check`, `ssl-gen`, `ssl-view`, `gpgls`, `gpgenc`, `gpgdec`, `sha256file`, `sha512file` |
| `13-database.sh` | Database shortcuts | `myconn`, `mydump`, `myls` (MySQL), `pgconn`, `pgdump`, `pgls` (Postgres), `rflush`, `rkeys` (Redis), `sqls` (SQLite) |
| `14-json.sh` | JSON helpers | `json-check`, `json-min`, `json-keys`, `json-diff`, `jqk` |
| `15-rsync.sh` | File sync and backup | `rcopy`, `rmirror`, `rbackup`, `rdry`, `rclonecopy`, `rclonesync`, `rcloneremotes` |
| `16-brew.sh` | Linuxbrew | `bup`, `bls`, `bins`, `brm`, `binfo`, `brewclean`, `brewoutd`, `bpin`, `bunpin` |
| `17-gh.sh` | GitHub CLI shortcuts | `ghpr`, `ghprc`, `ghclone`, `ghfork`, `ghissue`, `ghgist`, `ghrun`, `ghwatch`, `ghwho` |
| `18-nvm.sh` | Node version manager (lazy-loaded) | `nvminstall`, `nvmuse`, `nvmlts`, `nvmdefault`, `nvmls`, `nvmls-remote` |
| `19-editors.sh` | IDE and editor launchers | `code`, `idea`, `rider`, `phpstorm`, `datagrip`, `webstorm`, `goland`, `pycharm`, `clion` |
| `20-shell-tools.sh` | Shell linting and formatting | `sc` (shellcheck), `sfmt`, `sfmtcheck`, `sfmtdiff` |
| `21-tmux.sh` | tmux shortcuts | `tn`, `tls`, `tk`, `tka`, `cluster` |
| `22-docker.sh` | Docker | `dps`, `drun2`, `dstop`, `drm`, `dimg`, `dprune`, `dlogs`, `dex`, `dcb`, `dcu`, `dcd`, `dcl`, `dcheck` |
| `23-kubernetes.sh` | kubectl shortcuts | `kc` (kubectl), `kg`, `ka`, `kd`, `klogs`, `kns`, `kctx`, `kpods` |
| `24-cloud.sh` | AWS, GCP and Azure | `awsls`, `awsp`, `awswho`, `awsec2`, `awslambda` (AWS), `gcls`, `gcwho` (GCP), `azls`, `azwho`, `azgroup` (Azure) |
| `25-devops.sh` | Terraform and Ansible | `tfi`, `tfp`, `tfa`, `tfd`, `tfo`, `tfst`, `tfw` (Terraform), `ap`, `apcheck`, `aping`, `ard` (Ansible) |
| `26-python.sh` | Python | `py`, `pip`, `venv`, `activate`, `ptest`, `pfmt`, `plint`, `djr`, `djm`, `djtest` |
| `27-web.sh` | Node.js and npm | `ni`, `nr`, `nd`, `nb`, `ns`, `nt`, `nlint`, `nfmt`, `nout`, `naudit` |
| `28-ruby.sh` | Ruby, Bundler, Rails | `be`, `binst`, `bupd`, `brewclean`/`brewoutd` (renamed to avoid clashing with Bundler's own `bclean`/`boutd`), `rs`, `rdm`, `rspec`, `rubocop` |
| `29-php.sh` | PHP and Composer | `cupdate`, `creq`, `cdump`, `punit`, `pint`, `pserve` |
| `30-go.sh` | Go toolchain | `gor`, `gob`, `got`, `gfmt`, `govet`, `gomod`, `goup` |
| `31-rust.sh` | Cargo | `cr`, `cb`, `cbr`, `ct`, `ccheck`, `cfmt`, `cclippy` |
| `32-java.sh` | Maven and Gradle wrapper | `mvnt`, `mvnb`, `mvni`, `mvnc`, `gwb`, `gwt`, `gwr` |
| `33-c-cpp.sh` | GCC, Clang, LLDB, binary inspection | `cc2`, `ccrun`, `ccdbg`, `ccsan`, `cfmt2`, `ctidy`, `symbols` |
| `34-starship.sh` | Starship prompt | Initialises the Starship cross-shell prompt (config in `linux/starship.toml`) |
| `35-secrets.sh` | age and sops secrets encryption | `agenew`, `agenc`, `agedec`, `sopsenc`, `sopsdec`, `sopsedit`, `sopsview` |

## Adding a topic

Create a new file with the next available number, e.g. `36-mytopic.sh`. It is sourced automatically. There is no need to edit `bashrc`.

## Platform differences from macOS

- `copy`/`paste` use `xclip` instead of `pbcopy`/`pbpaste`
- `dns-flush` clears the Linux DNS cache (`systemd-resolve --flush-caches`)
- `16-brew.sh` covers Linuxbrew - no `binsc` (cask) or `boutd` (macOS-specific cask update)
