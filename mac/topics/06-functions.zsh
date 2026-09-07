# =============================================================================
# Shell functions
# Functions I use daily that are too complex for a single alias. I keep these
# before language sections so they're available regardless of which tools are
# installed on a given machine.
# =============================================================================

# mkcd: create a directory and cd into it in one step.
# Uses 'command mkdir' to bypass the mkdir -pv alias and avoid duplicate flags.
mkcd() {
    command mkdir -p "$1" && cd "$1" || return
}

# cls: hard-clear the terminal (including scrollback) and reprint the welcome banner.
# The \033[2J\033[3J\033[H sequence clears both the visible screen and the scrollback
# buffer - plain 'clear' only clears the visible area.
cls() {
    printf '\033[2J\033[3J\033[H'
    echo ""
    echo "${BOLD}${CYAN}---------------------------------------------${RESET}"
    echo "${BOLD}${CYAN}  🚀 Welcome back, Isaac!${RESET}"
    echo "${GREEN}  ✅ macOS profile loaded${RESET}"
    echo "${GREEN}  💻 $(scutil --get ComputerName) - zsh${RESET}"
    echo "${YELLOW}  📅 $(date '+%a %d %b %Y  %H:%M')${RESET}"
    echo "${BOLD}${CYAN}---------------------------------------------${RESET}"
    echo ""
}

# dot: pull the latest dotfiles from the remote and apply the mac profile.
# I run this after making changes on another machine to get them onto this one.
dot() {
    echo "${CYAN}Pulling latest dotfiles...${RESET}"
    git -C "$DOTFILES" pull
    echo "${CYAN}Applying mac profile...${RESET}"
    cp "$DOTFILES/mac/zshrc" ~/.zshrc
    # shellcheck disable=SC1090
    source ~/.zshrc
    echo "${GREEN}Done - dotfiles are up to date${RESET}"
}

# listcmds: the live, raw counterpart to cmds() below. cmds() is a curated, hand-written
# cheat-sheet, this instead dumps every alias, function and PATH executable actually loaded
# right now, useful for checking what is really active rather than what the docs claim.
listcmds() {
    echo "${BOLD}${CYAN}=== Aliases ===${RESET}"
    alias
    echo ""
    echo "${BOLD}${CYAN}=== Functions ===${RESET}"
    functions
    echo ""
    echo "${BOLD}${CYAN}=== Executables in PATH (unique) ===${RESET}"
    # shellcheck disable=SC2296
    for d in ${(s/:/)PATH}; do
        ls -1 "$d" 2>/dev/null
    done | sort -u
    echo ""
    echo "${WHITE}Inspect a command's type: use 'whence -v <name>' or 'type -a <name>'${RESET}"
}
alias lc=listcmds

# cmds: list all custom aliases and functions with short descriptions.
# Piped through less so real scrolling works on output this long and mouse-wheel scroll is
# handled by less itself instead of leaking through as arrow keys onto the shell prompt
# underneath, the same mechanism git diff and man already use. Press q to exit.
cmds() {
    _cmds_body | less -RF
}
_cmds_body() {
    echo ""
    echo "${BOLD}${CYAN}=== Custom commands (type cmds to see this again, q to exit) ===${RESET}"
    echo "  ${MAGENTA}magenta = category${RESET}   ${CYAN}cyan = commands${RESET}   ${WHITE}white = descriptions${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}NAVIGATION${RESET}"
    echo "  ${CYAN}dev / downloads${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}GIT${RESET}"
    echo "  ${CYAN}gs / ga / gaa / gcmt / gpsh / gcp / gpul${RESET}   ${WHITE}status/add/commit/push/pull${RESET}"
    echo "  ${CYAN}glog / gco / gcb / gb / gd${RESET}           ${WHITE}log/checkout/branch/diff${RESET}"
    echo "  ${CYAN}gundo / gbd / gclean${RESET}                 ${WHITE}undo/delete branch/clean${RESET}"
    echo "  ${CYAN}automerge${RESET}                            ${WHITE}squash auto-merge the current PR and delete the branch${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}REPOS${RESET}"
    echo "  ${CYAN}pull-all${RESET}      ${WHITE}pull all repos in a directory${RESET}"
    echo "  ${CYAN}repo-status${RESET}   ${WHITE}show branch and clean/dirty state for every repo${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}SYSTEM${RESET}"
    echo "  ${CYAN}ll / la${RESET}         ${WHITE}ls -lah / ls -la${RESET}"
    echo "  ${CYAN}mkdir${RESET}           ${WHITE}mkdir -pv (creates parent dirs, verbose)${RESET}"
    echo "  ${CYAN}mkcd${RESET}            ${WHITE}mkdir + cd in one step${RESET}"
    echo "  ${CYAN}cls${RESET}             ${WHITE}hard-clear terminal and reprint welcome banner${RESET}"
    echo "  ${CYAN}edit-profile${RESET}    ${WHITE}open ~/.zshrc in VS Code${RESET}"
    echo "  ${CYAN}reload-profile${RESET}  ${WHITE}source ~/.zshrc${RESET}"
    echo "  ${CYAN}dot${RESET}             ${WHITE}pull latest dotfiles and apply them${RESET}"
    echo "  ${CYAN}cmds${RESET}            ${WHITE}show this command reference (q to exit)${RESET}"
    echo "  ${CYAN}lc / listcmds${RESET}   ${WHITE}dump every alias, function and PATH executable actually loaded${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}UTILITIES${RESET}"
    echo "  ${CYAN}serve${RESET}         ${WHITE}python3 -m http.server 8080${RESET}"
    echo "  ${CYAN}pubip / myip${RESET}  ${WHITE}local public IP shortcuts${RESET}"
    echo "  ${CYAN}weather${RESET}       ${WHITE}terminal weather via wttr.in${RESET}"
    echo "  ${CYAN}duh${RESET}           ${WHITE}disk usage of current dir sorted by size${RESET}"
    echo "  ${CYAN}psgrep${RESET}        ${WHITE}ps aux | grep${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}COMMUNITY TOOLS${RESET}"
    echo "  ${CYAN}extract${RESET}           ${WHITE}unpack any archive (tar, zip, rar, 7z, gz, bz2...)${RESET}"
    echo "  ${CYAN}targz / gz${RESET}        ${WHITE}create .tar.gz / show compression ratio${RESET}"
    echo "  ${CYAN}dataurl${RESET}           ${WHITE}encode a file as a base64 data URL${RESET}"
    echo "  ${CYAN}envup${RESET}             ${WHITE}load a .env file into the current shell${RESET}"
    echo "  ${CYAN}digga${RESET}             ${WHITE}show all DNS records for a domain${RESET}"
    echo "  ${CYAN}dns-flush${RESET}         ${WHITE}flush the macOS DNS cache${RESET}"
    echo "  ${CYAN}cdf${RESET}               ${WHITE}cd to the current Finder window location${RESET}"
    echo "  ${CYAN}clipcopy / paste${RESET}  ${WHITE}pbcopy / pbpaste${RESET}"
    echo "  ${CYAN}change-extension${RESET}  ${WHITE}batch rename extensions (e.g. erb haml)${RESET}"
    echo "  ${CYAN}GET / POST / PUT / DELETE / HEAD${RESET}   ${WHITE}curl HTTP shortcuts${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}BREW${RESET}"
    echo "  ${CYAN}bins / binsc${RESET}                         ${WHITE}brew install / brew install --cask${RESET}"
    echo "  ${CYAN}brm${RESET}                                  ${WHITE}brew uninstall${RESET}"
    echo "  ${CYAN}bls / blsc${RESET}                           ${WHITE}brew list / brew list --cask${RESET}"
    echo "  ${CYAN}brewoutd${RESET}                             ${WHITE}brew outdated${RESET}"
    echo "  ${CYAN}bsearch / binfo / bdr / brewclean${RESET}    ${WHITE}search/info/doctor/cleanup${RESET}"
    echo "  ${CYAN}bpin / bunpin / bdeps / bleave${RESET}       ${WHITE}pin/unpin/deps/autoremove${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}GLOBAL PIPE SHORTCUTS (zsh only)${RESET}"
    echo "  ${CYAN}G / H / T / L / N${RESET}   ${WHITE}| grep / head / tail / less / wc -l${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}SSH${RESET}"
    echo "  ${CYAN}node1-4${RESET}   ${WHITE}ssh node1/node2/node3/node4 (cluster shortcuts)${RESET}"
    echo "  ${CYAN}sshconf${RESET}   ${WHITE}open ~/.ssh/config in VS Code${RESET}"
    echo "  ${CYAN}sshls${RESET}     ${WHITE}list loaded SSH keys (ssh-add -l)${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}NETWORK${RESET}"
    echo "  ${CYAN}ips / localip${RESET}   ${WHITE}list local IPs / current en0 IP${RESET}"
    echo "  ${CYAN}openports${RESET}       ${WHITE}lsof -i (listening ports)${RESET}"
    echo "  ${CYAN}ping4${RESET}           ${WHITE}ping -c 4${RESET}"
    echo "  ${CYAN}speedtest${RESET}       ${WHITE}run a network speed test${RESET}"
    echo "  ${CYAN}tracepath / wh${RESET}  ${WHITE}traceroute / whois${RESET}"
    echo "  ${CYAN}nginx-test / nginx-reload / nginx-restart / nginx-log${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}SECURITY / CRYPTO${RESET}"
    echo "  ${CYAN}md5 / sha1 / sha256 / sha512${RESET}    ${WHITE}file checksums${RESET}"
    echo "  ${CYAN}gpgls / gpglss${RESET}                  ${WHITE}list public / secret keys${RESET}"
    echo "  ${CYAN}gpgenc / gpgdec${RESET}                 ${WHITE}encrypt / decrypt${RESET}"
    echo "  ${CYAN}gpgsign / gpgverify${RESET}             ${WHITE}sign / verify${RESET}"
    echo "  ${CYAN}gpgexport / gpgimport${RESET}           ${WHITE}export / import a key${RESET}"
    echo "  ${CYAN}nikto${RESET}                           ${WHITE}web server vulnerability scanner${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}DATABASE${RESET}"
    echo "  ${CYAN}pgls / pgdump / pgrestore / pgsize / pgusers${RESET}   ${WHITE}PostgreSQL${RESET}"
    echo "  ${CYAN}myls / mydump${RESET}                                   ${WHITE}MySQL${RESET}"
    echo "  ${CYAN}mconn / mdbs${RESET}                                    ${WHITE}MongoDB (mongosh)${RESET}"
    echo "  ${CYAN}rcli / rping / rkeys / rinfo / rmon / rflush${RESET}    ${WHITE}Redis${RESET}"
    echo "  ${CYAN}sq / influx${RESET}                                      ${WHITE}SQLite / InfluxDB${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}JSON${RESET}"
    echo "  ${CYAN}jqk / jqf / jqlen / json-keys / json-min${RESET}"
    echo "  ${WHITE}(pretty-print / raw output / length / keys / minify)${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}FILE SYNC (rclone)${RESET}"
    echo "  ${CYAN}rclonecopy / rclonesync / rcloneremotes / rls${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}EDITORS${RESET}"
    echo "  ${CYAN}e / ec${RESET}                       ${WHITE}code . / code (VS Code)${RESET}"
    echo "  ${CYAN}extinstall / extls / extrm${RESET}   ${WHITE}VS Code extension management${RESET}"
    echo "  ${CYAN}nvimconf${RESET}                     ${WHITE}open nvim config in VS Code${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}SHELL TOOLS${RESET}"
    echo "  ${CYAN}sfmt / sfmtcheck / sfmtdiff${RESET}   ${WHITE}shfmt (format/check/diff shell scripts)${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}TMUX${RESET}"
    echo "  ${CYAN}tls / ts / tss / tw / tka / tconf / tlog${RESET}"
    echo "  ${WHITE}(list-sessions / split-v / split-h / new-window / kill-server / reload / capture)${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}GITHUB CLI${RESET}"
    echo "  ${CYAN}ghclone / ghfork / ghrepo / ghwho${RESET}"
    echo "  ${CYAN}ghprc / ghprl / ghprv / ghprs / ghprco / ghprm${RESET}   ${WHITE}pull requests${RESET}"
    echo "  ${CYAN}ghissc / ghissl / ghissv / ghissclose${RESET}             ${WHITE}issues${RESET}"
    echo "  ${CYAN}ghrun / ghwatch / ghfail${RESET}                          ${WHITE}workflow runs${RESET}"
    echo "  ${CYAN}ghrls / ghrlsc${RESET}   ${WHITE}releases${RESET}   |   ${CYAN}ghgist / ghgistc${RESET}   ${WHITE}gists${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}NVM${RESET}"
    echo "  ${CYAN}nvmuse / nvmls / nvmls-remote / nvminstall / nvmdefault / nvmlts${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}PYTHON${RESET}"
    echo "  ${CYAN}py / pip / venv / activate / ptest / plint / pfmt / preqs${RESET}"
    echo "  ${CYAN}djr / djm / djmm / djs / djc${RESET}   ${WHITE}Django manage.py shortcuts${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}JAVASCRIPT / NODE / TYPESCRIPT${RESET}"
    echo "  ${CYAN}ni / nid / nr / nd / nb / ns / nt / nlint / nfmt${RESET}"
    echo "  ${WHITE}(install / install-dev / run / dev / build / start / test / lint / format)${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}RUBY / RAILS${RESET}"
    echo "  ${CYAN}rb / irb${RESET}                          ${WHITE}ruby / interactive REPL${RESET}"
    echo "  ${CYAN}be / binst / bcheck / bupd / bclean${RESET}   ${WHITE}Bundler${RESET}"
    echo "  ${CYAN}rspec / rspecf / rubocop / rubofix${RESET}    ${WHITE}testing and linting${RESET}"
    echo "  ${CYAN}rs / rc / rd / rg / rrout${RESET}            ${WHITE}Rails server/console/migrate/generate/routes${RESET}"
    echo "  ${CYAN}rdc / rdd / rdr / rds${RESET}               ${WHITE}Rails db:create/drop/reset/seed${RESET}"
    echo "  ${CYAN}rbinstall / rbls / rbuse / rbglobal${RESET}  ${WHITE}rbenv version management${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}PHP / LARAVEL${RESET}"
    echo "  ${CYAN}pa / par / pat / pserve${RESET}              ${WHITE}artisan / serve / tinker / built-in server${RESET}"
    echo "  ${CYAN}pam / pamm / pamc / pamr / pamfs / pads${RESET}   ${WHITE}migrations and seeding${RESET}"
    echo "  ${CYAN}parl / paq / paoc${RESET}                    ${WHITE}routes / queue / clear caches${RESET}"
    echo "  ${CYAN}ci / cupdate / creq / cdump / coutdated${RESET}   ${WHITE}Composer${RESET}"
    echo "  ${CYAN}punit / pint${RESET}                         ${WHITE}PHPUnit / Laravel Pint${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}GO${RESET}"
    echo "  ${CYAN}gor / gob / got / gfmt / govet / gomod${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}RUST${RESET}"
    echo "  ${CYAN}cr / cb / cbr / ct / ccheck / cfmt / cclean${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}JAVA / BUILD TOOLS${RESET}"
    echo "  ${CYAN}mvnt / mvnb / mvni / mvnc / mvncb${RESET}   ${WHITE}Maven${RESET}"
    echo "  ${CYAN}gwb / gwt / gwr / gwc / gwcb${RESET}        ${WHITE}Gradle wrapper${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}C / C++${RESET}"
    echo "  ${CYAN}cc2 / ccrun / ccdbg / ccsan${RESET}      ${WHITE}compile / compile+run / debug build / sanitizers (C)${RESET}"
    echo "  ${CYAN}cppc / cpprun / cppdbg / cppsan${RESET}  ${WHITE}same, for C++ (C++20)${RESET}"
    echo "  ${CYAN}cfmt2 / ctidy / dbg${RESET}              ${WHITE}clang-format / clang-tidy / lldb${RESET}"
    echo "  ${CYAN}bsize / hd / odump / symbols${RESET}     ${WHITE}binary inspection${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}DOCKER${RESET}"
    echo "  ${CYAN}dps / dpa / dex / dlogs / dstop / drm / dimg / dprune${RESET}"
    echo "  ${CYAN}dcu / dcud / dcd / dcb / dcl${RESET}   ${WHITE}Docker Compose${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}KUBERNETES${RESET}"
    echo "  ${CYAN}kc / kg / ka / kd / klogs / kns / kctx / kpods${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}CLOUD${RESET}"
    echo "  ${CYAN}awsls / awswho / awsec2 / awslambda${RESET}   ${WHITE}AWS${RESET}"
    echo "  ${CYAN}azls / azwho / azgroup / azweb${RESET}        ${WHITE}Azure${RESET}"
    echo "  ${CYAN}gcwho / gcfg / gcvms / gcrun / gcbuild${RESET}   ${WHITE}GCP${RESET}"
    echo ""

    echo "${BOLD}${MAGENTA}DEVOPS / IaC${RESET}"
    echo "  ${CYAN}tfi / tfp / tfa / tfaa / tfd / tfda / tff / tfv${RESET}              ${WHITE}Terraform plan/apply/destroy/fmt${RESET}"
    echo "  ${CYAN}tfs / tfo / tfst / tfw / tfwn / tfwsel${RESET}                       ${WHITE}Terraform state/output/workspace${RESET}"
    echo "  ${CYAN}hinst / hup / hupi / hrm / hls / hlsa / hsearch / hvals / hdiff${RESET}   ${WHITE}Helm${RESET}"
    echo "  ${CYAN}hrepo / hrepoadd / hrepoup${RESET}                                   ${WHITE}Helm repos${RESET}"
    echo "  ${CYAN}vup / vssh / vhalt / vreload / vdestroy / vstatus / vsnap${RESET}    ${WHITE}Vagrant${RESET}"
    echo "  ${CYAN}aping / ai${RESET}                                                    ${WHITE}Ansible ping / inventory${RESET}"
    echo ""

}
