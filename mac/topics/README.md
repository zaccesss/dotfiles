# mac/topics/

35 numbered `.zsh` files loaded in order by `../zshrc`. Each file covers one topic area. Add a new file with the next available number to extend the profile - it is picked up automatically at the next shell start.

## Topic files

| File | Topic | Key commands |
| --- | --- | --- |
| `01-path.zsh` | PATH and environment | Homebrew, `~/bin`, language runtime paths added to `$PATH` |
| `02-colours.zsh` | Terminal colour variables | `BOLD`, `DIM`, `RESET`, `RED`, `GREEN`, `YELLOW`, `CYAN`, `BLUE`, `WHITE` |
| `03-navigation.zsh` | Directory shortcuts | `dev`, `downloads` |
| `04-git.zsh` | Git aliases and helpers | `gs`, `ga`, `gaa`, `gcmt`, `gpsh`, `gcp`, `gpul`, `glog`, `gco`, `gcb`, `gb`, `gbd`, `gd`, `gundo`, `gclean`, `automerge`, `pull-all`, `repo-status` |
| `05-profile.zsh` | Profile management | `edit-profile`, `reload-profile` |
| `06-functions.zsh` | Core functions and command reference | `mkcd`, `cls`, `dot`, `cmds` |
| `07-utilities.zsh` | General utilities | `ll`, `la`, `mkdir`, `duh`, `psgrep`, `serve`, `pubip`, `weather` |
| `08-community.zsh` | Community-borrowed utilities | `extract`, `targz`, `gz`, `dataurl`, `envup`, `digga`, `dns-flush`, `cdf`, `clipcopy`, `paste` |
| `09-cli-tools.zsh` | Modern CLI tools, text processing and process/port utilities | `z`, `zi` (zoxide), `ff`, `fcd`, `fh` (fzf), `ez`, `ezl`, `ezt` (eza), `rg2` (ripgrep), `col`, `replace`, `whatport`, `killport`, `notify` |
| `10-ssh.zsh` | SSH helpers | `keygen`, `sshcp`, `ssha`, `sshls`, `sshconf`, `sshtest` |
| `11-network.zsh` | Network diagnostics | `myip`, `localip`, `ips`, `headers`, `scan`, `portscan`, `openports`, `dns`, `tracepath`, `speedtest`, `ping4`, `portcheck`, `nginx-test`, `nginx-reload`, `nginx-restart`, `nginx-log` |
| `12-security.zsh` | SSL, GPG and crypto | `ssl-check`, `ssl-gen`, `ssl-view`, `gpgls`, `gpgenc`, `gpgdec`, `sha256file`, `sha512file` |
| `13-database.zsh` | Database shortcuts | `myconn`, `mydump`, `myls` (MySQL), `pgconn`, `pgdump`, `pgls` (Postgres), `rflush`, `rkeys` (Redis), `sqls` (SQLite) |
| `14-json.zsh` | JSON helpers | `json-check`, `json-min`, `json-keys`, `json-diff`, `jqk` |
| `15-rsync.zsh` | File sync and backup | `rcopy`, `rmirror`, `rbackup`, `rdry`, `rclonecopy`, `rclonesync`, `rcloneremotes` |
| `16-brew.zsh` | Homebrew | `bup`, `bls`, `blsc`, `bins`, `binsc`, `brm`, `binfo`, `brewclean`, `brewoutd`, `bpin`, `bunpin` |
| `17-gh.zsh` | GitHub CLI shortcuts | `ghpr`, `ghprc`, `ghclone`, `ghfork`, `ghissue`, `ghgist`, `ghrun`, `ghwatch`, `ghwho` |
| `18-nvm.zsh` | Node version manager (lazy-loaded) | `nvminstall`, `nvmuse`, `nvmlts`, `nvmdefault`, `nvmls`, `nvmls-remote` |
| `19-editors.zsh` | IDE and editor launchers | `code`, `idea`, `rider`, `phpstorm`, `datagrip`, `webstorm`, `goland`, `pycharm`, `clion` |
| `20-shell-tools.zsh` | Shell linting and formatting | `sc`, `scwatch`, `sfmt`, `sfmtdiff`, `sfmtcheck`, `zshn`, `bashn`, `sc-all` |
| `21-tmux.zsh` | tmux shortcuts | `ta`, `tn`, `tls`, `tk`, `tka`, `tw`, `ts`, `tss`, `tconf`, `tlog`, `cluster` |
| `22-docker.zsh` | Docker | `dps`, `dpa`, `dex`, `dlogs`, `dstop`, `drm`, `dimg`, `dprune`, `dcu`, `dcud`, `dcd`, `dcb`, `dcl` |
| `23-kubernetes.zsh` | kubectl shortcuts | `kc` (kubectl), `kg`, `ka`, `kd`, `klogs`, `kns`, `kctx`, `kpods` |
| `24-cloud.zsh` | AWS, GCP and Azure | `awsp`, `awswho`, `awsls`, `awsec2`, `awslogs`, `awslambda`, `awsregion` (AWS), `gcfg`, `gcproj`, `gcwho`, `gcrun`, `gcbuild`, `gcvms`, `gclogs` (GCP), `azwho`, `azls`, `azsub`, `azvm`, `azweb`, `azgroup`, `azlogs` (Azure) |
| `25-devops.zsh` | Terraform, Ansible, Helm and Vagrant | `tfi`, `tfp`, `tfa`, `tfaa`, `tfd`, `tfda`, `tfv`, `tff`, `tfo`, `tfs`, `tfst`, `tfw`, `tfwn`, `tfwsel`, `tfplan-save` (Terraform), `ap`, `apcheck`, `ai`, `aping` (Ansible), `hls`, `hlsa`, `hinst`, `hup`, `hrm`, `hrepo`, `hrepoadd`, `hrepoup`, `hsearch`, `hvals` (Helm), `vup`, `vhalt`, `vreload`, `vssh`, `vdestroy`, `vstatus`, `vsnap` (Vagrant) |
| `26-python.zsh` | Python | `py`, `pip`, `venv`, `activate`, `ptest`, `pfmt`, `plint`, `djr`, `djm`, `djtest` |
| `27-web.zsh` | Node.js and npm | `ni`, `nr`, `nd`, `nb`, `ns`, `nt`, `nlint`, `nfmt`, `nout`, `naudit` |
| `28-ruby.zsh` | Ruby, Bundler, Rails | `be`, `binst`, `bupd`, `brewclean`/`brewoutd` (renamed to avoid clashing with Bundler's own `bclean`/`boutd`), `rs`, `rdm`, `rspec`, `rubocop` |
| `29-php.zsh` | PHP and Composer | `cupdate`, `creq`, `cdump`, `punit`, `pint`, `pserve` |
| `30-go.zsh` | Go toolchain | `gor`, `gob`, `got`, `gfmt`, `govet`, `gomod`, `goup` |
| `31-rust.zsh` | Cargo | `cr`, `cb`, `cbr`, `ct`, `ccheck`, `cfmt`, `cclippy` |
| `32-java.zsh` | Maven and Gradle wrapper | `mvnt`, `mvnb`, `mvni`, `mvnc`, `gwb`, `gwt`, `gwr` |
| `33-c-cpp.zsh` | GCC, Clang, LLDB, binary inspection | `cc2`, `ccrun`, `ccdbg`, `ccsan`, `cfmt2`, `ctidy`, `symbols` |
| `34-starship.zsh` | Starship prompt | Initialises the Starship cross-shell prompt (config in `mac/starship.toml`) |
| `35-secrets.zsh` | age and sops secrets encryption | `agenew`, `agenc`, `agedec`, `sopsenc`, `sopsdec`, `sopsedit`, `sopsview` |

## Adding a topic

Create a new file with the next available number, e.g. `36-mytopic.zsh`. It is sourced automatically. There is no need to edit `zshrc`.

## Naming conflicts

Files are loaded in numerical order so a higher-numbered file overrides an identically-named alias from a lower-numbered one. See [journal/003-alias-conflicts.md](../../journal/003-alias-conflicts.md) for the conflicts found so far.
