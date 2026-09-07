# =============================================================================
# Shell functions
# Core functions available on every Linux machine regardless of which language
# tools are installed. Identical in purpose to the mac equivalents; bash
# syntax is used instead of zsh throughout.
# =============================================================================

# mkcd: create a directory and cd into it in one step.
# Uses 'command mkdir' to bypass the mkdir -pv alias and avoid duplicate flags.
mkcd() {
    command mkdir -p "$1" && cd "$1" || return
}

# cls: hard-clear the terminal (including scrollback) and reprint the welcome banner.
# The \033[2J\033[3J\033[H sequence clears both visible screen and scrollback buffer.
cls() {
    printf '\033[2J\033[3J\033[H'
    echo ""
    echo -e "${BOLD}${CYAN}---------------------------------------------${RESET}"
    echo -e "${BOLD}${CYAN}  🚀 Welcome back, Isaac!${RESET}"
    echo -e "${GREEN}  ✅ Linux profile loaded${RESET}"
    echo -e "${GREEN}  💻 $(hostname) - bash${RESET}"
    echo -e "${YELLOW}  📅 $(date '+%a %d %b %Y  %H:%M')${RESET}"
    echo -e "${BOLD}${CYAN}---------------------------------------------${RESET}"
    echo ""
}

# dot: pull the latest dotfiles and apply the Linux profile.
dot() {
    echo -e "${CYAN}Pulling latest dotfiles...${RESET}"
    git -C "$DOTFILES" pull
    echo -e "${CYAN}Applying Linux profile...${RESET}"
    cp "$DOTFILES/linux/bashrc" ~/.bashrc
    # shellcheck disable=SC1090
    source ~/.bashrc
    echo -e "${GREEN}Done - dotfiles are up to date${RESET}"
}


# listcmds: the live, raw counterpart to cmds() below. cmds() is a curated, hand-written
# cheat-sheet, this instead dumps every alias, function and PATH executable actually loaded
# right now, useful for checking what is really active rather than what the docs claim.
listcmds() {
    echo -e "${BOLD}${CYAN}=== Aliases ===${RESET}"
    alias
    echo ""
    echo -e "${BOLD}${CYAN}=== Functions ===${RESET}"
    compgen -A function
    echo ""
    echo -e "${BOLD}${CYAN}=== Executables in PATH (unique) ===${RESET}"
    local IFS=:
    for d in $PATH; do
        ls -1 "$d" 2>/dev/null
    done | sort -u
    echo ""
    echo -e "${WHITE}Inspect a command's type: use 'type -a <name>' or 'command -v <name>'${RESET}"
}
alias lc='listcmds'

# cmds: list all custom aliases and functions with short descriptions.
# Piped through less so real scrolling works on output this long and mouse-wheel scroll is
# handled by less itself instead of leaking through as arrow keys onto the shell prompt
# underneath, the same mechanism git diff and man already use. Press q to exit.
cmds() {
    _cmds_body | less -RF
}
_cmds_body() {
    echo ""
    echo -e "${BOLD}${CYAN}=== Custom commands (type cmds to see this again, q to exit) ===${RESET}"
    echo -e "  ${MAGENTA}magenta = category${RESET}   ${CYAN}cyan = commands${RESET}   ${WHITE}white = descriptions${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}NAVIGATION${RESET}"
    echo -e "  ${CYAN}dev / downloads${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}GIT${RESET}"
    echo -e "  ${CYAN}gs / ga / gaa / gcmt / gpsh / gcp / gpul${RESET}   ${WHITE}status/add/commit/push/pull${RESET}"
    echo -e "  ${CYAN}glog / gco / gcb / gb / gd${RESET}           ${WHITE}log/checkout/branch/diff${RESET}"
    echo -e "  ${CYAN}gundo / gbd / gclean${RESET}                 ${WHITE}undo/delete branch/clean${RESET}"
    echo -e "  ${CYAN}automerge${RESET}                            ${WHITE}squash auto-merge the current PR and delete the branch${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}REPOS${RESET}"
    echo -e "  ${CYAN}pull-all${RESET}      ${WHITE}pull all repos in a directory${RESET}"
    echo -e "  ${CYAN}repo-status${RESET}   ${WHITE}show branch and clean/dirty state for every repo${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}SYSTEM${RESET}"
    echo -e "  ${CYAN}ll / la${RESET}         ${WHITE}ls -lah / ls -la${RESET}"
    echo -e "  ${CYAN}mkdir${RESET}           ${WHITE}mkdir -pv (creates parent dirs, verbose)${RESET}"
    echo -e "  ${CYAN}mkcd${RESET}            ${WHITE}mkdir + cd in one step${RESET}"
    echo -e "  ${CYAN}cls${RESET}             ${WHITE}hard-clear terminal (including scrollback) and reprint welcome banner${RESET}"
    echo -e "  ${CYAN}edit-profile${RESET}    ${WHITE}open ~/.bashrc in VS Code${RESET}"
    echo -e "  ${CYAN}reload-profile${RESET}  ${WHITE}source ~/.bashrc${RESET}"
    echo -e "  ${CYAN}dot${RESET}             ${WHITE}pull latest dotfiles and apply them${RESET}"
    echo -e "  ${CYAN}cmds${RESET}            ${WHITE}show this command reference (q to exit)${RESET}"
    echo -e "  ${CYAN}lc / listcmds${RESET}   ${WHITE}dump every alias, function and PATH executable actually loaded${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}UTILITIES${RESET}"
    echo -e "  ${CYAN}serve${RESET}         ${WHITE}python3 -m http.server 8080${RESET}"
    echo -e "  ${CYAN}pubip / myip${RESET}  ${WHITE}local public IP shortcuts${RESET}"
    echo -e "  ${CYAN}weather${RESET}       ${WHITE}terminal weather via wttr.in${RESET}"
    echo -e "  ${CYAN}duh${RESET}           ${WHITE}disk usage of current dir sorted by size${RESET}"
    echo -e "  ${CYAN}psgrep${RESET}        ${WHITE}ps aux | grep${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}COMMUNITY TOOLS${RESET}"
    echo -e "  ${CYAN}extract${RESET}           ${WHITE}unpack any archive (tar, zip, rar, 7z, gz, bz2...)${RESET}"
    echo -e "  ${CYAN}targz / gz${RESET}        ${WHITE}create .tar.gz / show compression ratio${RESET}"
    echo -e "  ${CYAN}dataurl${RESET}           ${WHITE}encode a file as a base64 data URL${RESET}"
    echo -e "  ${CYAN}envup${RESET}             ${WHITE}load a .env file into the current shell${RESET}"
    echo -e "  ${CYAN}digga${RESET}             ${WHITE}show all DNS records for a domain${RESET}"
    echo -e "  ${CYAN}dns-flush${RESET}         ${WHITE}flush the Linux DNS cache${RESET}"
    echo -e "  ${CYAN}clipcopy / paste${RESET}  ${WHITE}xclip (pipe to / read from clipboard)${RESET}"
    echo -e "  ${CYAN}change-extension${RESET}  ${WHITE}batch rename extensions (e.g. erb haml)${RESET}"
    echo -e "  ${CYAN}GET / POST / PUT / DELETE / HEAD${RESET}   ${WHITE}curl HTTP shortcuts${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}BREW (Linuxbrew)${RESET}"
    echo -e "  ${CYAN}bins / brm${RESET}                         ${WHITE}brew install / brew uninstall${RESET}"
    echo -e "  ${CYAN}bls / blsc${RESET}                         ${WHITE}brew list / brew list --cask${RESET}"
    echo -e "  ${CYAN}bsearch / binfo / bdr / brewclean${RESET}  ${WHITE}search/info/doctor/cleanup${RESET}"
    echo -e "  ${CYAN}bpin / bunpin / bdeps / bleave${RESET}      ${WHITE}pin/unpin/deps/autoremove${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}SSH${RESET}"
    echo -e "  ${CYAN}node1-4${RESET}   ${WHITE}ssh node1/node2/node3/node4 (cluster shortcuts)${RESET}"
    echo -e "  ${CYAN}sshconf${RESET}   ${WHITE}open ~/.ssh/config in VS Code${RESET}"
    echo -e "  ${CYAN}sshls${RESET}     ${WHITE}list loaded SSH keys (ssh-add -l)${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}NETWORK${RESET}"
    echo -e "  ${CYAN}ips / myip${RESET}    ${WHITE}list local IPs / public IP${RESET}"
    echo -e "  ${CYAN}openports${RESET}     ${WHITE}netstat or lsof (listening ports)${RESET}"
    echo -e "  ${CYAN}ping4${RESET}         ${WHITE}ping -c 4${RESET}"
    echo -e "  ${CYAN}speedtest${RESET}     ${WHITE}run a network speed test${RESET}"
    echo -e "  ${CYAN}tracepath / wh${RESET}   ${WHITE}traceroute / whois${RESET}"
    echo -e "  ${CYAN}nginx-test / nginx-reload / nginx-restart / nginx-log${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}SECURITY / CRYPTO${RESET}"
    echo -e "  ${CYAN}md5 / sha1 / sha256 / sha512${RESET}   ${WHITE}file checksums${RESET}"
    echo -e "  ${CYAN}gpgls / gpglss${RESET}    ${WHITE}list public / secret keys${RESET}"
    echo -e "  ${CYAN}gpgenc / gpgdec${RESET}   ${WHITE}encrypt / decrypt${RESET}"
    echo -e "  ${CYAN}gpgsign / gpgverify${RESET}   ${WHITE}sign / verify${RESET}"
    echo -e "  ${CYAN}gpgexport / gpgimport${RESET}   ${WHITE}export / import a key${RESET}"
    echo -e "  ${CYAN}nikto${RESET}         ${WHITE}web server vulnerability scanner${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}DATABASE${RESET}"
    echo -e "  ${CYAN}pgls / pgdump / pgrestore / pgsize / pgusers${RESET}   ${WHITE}PostgreSQL${RESET}"
    echo -e "  ${CYAN}myls / mydump${RESET}   ${WHITE}MySQL${RESET}"
    echo -e "  ${CYAN}mconn / mdbs${RESET}    ${WHITE}MongoDB (mongosh)${RESET}"
    echo -e "  ${CYAN}rcli / rping / rkeys / rinfo / rmon / rflush${RESET}   ${WHITE}Redis${RESET}"
    echo -e "  ${CYAN}sq / influx${RESET}   ${WHITE}SQLite / InfluxDB${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}JSON${RESET}"
    echo -e "  ${CYAN}jqk / jqf / jqlen / json-keys / json-min${RESET}"
    echo -e "  ${WHITE}(pretty-print / raw output / length / keys / minify)${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}FILE SYNC (rclone)${RESET}"
    echo -e "  ${CYAN}rclonecopy / rclonesync / rcloneremotes / rls${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}EDITORS${RESET}"
    echo -e "  ${CYAN}e / ec${RESET}        ${WHITE}code . / code (VS Code)${RESET}"
    echo -e "  ${CYAN}extinstall / extls / extrm${RESET}   ${WHITE}VS Code extension management${RESET}"
    echo -e "  ${CYAN}nvimconf${RESET}      ${WHITE}open nvim config in VS Code${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}SHELL TOOLS${RESET}"
    echo -e "  ${CYAN}sfmt / sfmtcheck / sfmtdiff${RESET}   ${WHITE}shfmt (format/check/diff shell scripts)${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}TMUX${RESET}"
    echo -e "  ${CYAN}tls / ts / tss / tw / tka / tconf / tlog${RESET}"
    echo -e "  ${WHITE}(list-sessions / split-v / split-h / new-window / kill-server / reload / capture)${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}GITHUB CLI${RESET}"
    echo -e "  ${CYAN}ghclone / ghfork / ghrepo / ghwho${RESET}"
    echo -e "  ${CYAN}ghprc / ghprl / ghprv / ghprs / ghprco / ghprm${RESET}   ${WHITE}pull requests${RESET}"
    echo -e "  ${CYAN}ghissc / ghissl / ghissv / ghissclose${RESET}   ${WHITE}issues${RESET}"
    echo -e "  ${CYAN}ghrun / ghwatch / ghfail${RESET}   ${WHITE}workflow runs${RESET}"
    echo -e "  ${CYAN}ghrls / ghrlsc${RESET}   ${WHITE}releases${RESET}   |   ${CYAN}ghgist / ghgistc${RESET}   ${WHITE}gists${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}NVM${RESET}"
    echo -e "  ${CYAN}nvmuse / nvmls / nvmls-remote / nvminstall / nvmdefault / nvmlts${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}PYTHON${RESET}"
    echo -e "  ${CYAN}py / pip / venv / activate / ptest / plint / pfmt / preqs${RESET}"
    echo -e "  ${CYAN}djr / djm / djmm / djs / djc${RESET}   ${WHITE}Django manage.py shortcuts${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}JAVASCRIPT / NODE / TYPESCRIPT${RESET}"
    echo -e "  ${CYAN}ni / nid / nr / nd / nb / ns / nt / nlint / nfmt${RESET}"
    echo -e "  ${WHITE}(install / install-dev / run / dev / build / start / test / lint / format)${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}RUBY / RAILS${RESET}"
    echo -e "  ${CYAN}rb / irb${RESET}   ${WHITE}ruby / interactive REPL${RESET}"
    echo -e "  ${CYAN}be / binst / bcheck / bupd / bclean${RESET}   ${WHITE}Bundler${RESET}"
    echo -e "  ${CYAN}rspec / rspecf / rubocop / rubofix${RESET}   ${WHITE}testing and linting${RESET}"
    echo -e "  ${CYAN}rs / rc / rd / rg / rrout${RESET}   ${WHITE}Rails server/console/migrate/generate/routes${RESET}"
    echo -e "  ${CYAN}rdc / rdd / rdr / rds${RESET}   ${WHITE}Rails db:create/drop/reset/seed${RESET}"
    echo -e "  ${CYAN}rbinstall / rbls / rbuse / rbglobal${RESET}   ${WHITE}rbenv version management${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}PHP / LARAVEL${RESET}"
    echo -e "  ${CYAN}pa / par / pat / pserve${RESET}   ${WHITE}artisan / serve / tinker / built-in server${RESET}"
    echo -e "  ${CYAN}pam / pamm / pamc / pamr / pamfs / pads${RESET}   ${WHITE}migrations and seeding${RESET}"
    echo -e "  ${CYAN}parl / paq / paoc${RESET}   ${WHITE}routes / queue / clear caches${RESET}"
    echo -e "  ${CYAN}ci / cupdate / creq / cdump / coutdated${RESET}   ${WHITE}Composer${RESET}"
    echo -e "  ${CYAN}punit / pint${RESET}   ${WHITE}PHPUnit / Laravel Pint${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}GO${RESET}"
    echo -e "  ${CYAN}gor / gob / got / gfmt / govet / gomod${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}RUST${RESET}"
    echo -e "  ${CYAN}cr / cb / cbr / ct / ccheck / cfmt / cclean${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}JAVA / BUILD TOOLS${RESET}"
    echo -e "  ${CYAN}mvnt / mvnb / mvni / mvnc / mvncb${RESET}   ${WHITE}Maven${RESET}"
    echo -e "  ${CYAN}gwb / gwt / gwr / gwc / gwcb${RESET}        ${WHITE}Gradle wrapper${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}C / C++${RESET}"
    echo -e "  ${CYAN}cc2 / ccrun / ccdbg / ccsan${RESET}   ${WHITE}compile / compile+run / debug build / sanitizers (C)${RESET}"
    echo -e "  ${CYAN}cppc / cpprun / cppdbg / cppsan${RESET}   ${WHITE}same, for C++ (C++20)${RESET}"
    echo -e "  ${CYAN}cfmt2 / ctidy / dbg${RESET}   ${WHITE}clang-format / clang-tidy / gdb${RESET}"
    echo -e "  ${CYAN}bsize / hd / odump / symbols${RESET}   ${WHITE}binary inspection${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}DOCKER${RESET}"
    echo -e "  ${CYAN}dps / dpa / dex / dlogs / dstop / drm / dimg / dprune${RESET}"
    echo -e "  ${CYAN}dcu / dcud / dcd / dcb / dcl${RESET}   ${WHITE}Docker Compose${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}KUBERNETES${RESET}"
    echo -e "  ${CYAN}kc / kg / ka / kd / klogs / kns / kctx / kpods${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}CLOUD${RESET}"
    echo -e "  ${CYAN}awsls / awswho / awsec2 / awslambda${RESET}   ${WHITE}AWS${RESET}"
    echo -e "  ${CYAN}azls / azwho / azgroup / azweb${RESET}   ${WHITE}Azure${RESET}"
    echo -e "  ${CYAN}gcwho / gcfg / gcvms / gcrun / gcbuild${RESET}   ${WHITE}GCP${RESET}"
    echo ""

    echo -e "${BOLD}${MAGENTA}DEVOPS / IaC${RESET}"
    echo -e "  ${CYAN}tfi / tfp / tfa / tfaa / tfd / tfda / tff / tfv${RESET}   ${WHITE}Terraform plan/apply/destroy/fmt${RESET}"
    echo -e "  ${CYAN}tfs / tfo / tfst / tfw / tfwn / tfwsel${RESET}   ${WHITE}Terraform state/output/workspace${RESET}"
    echo -e "  ${CYAN}hinst / hup / hupi / hrm / hls / hlsa / hsearch / hvals / hdiff${RESET}   ${WHITE}Helm${RESET}"
    echo -e "  ${CYAN}hrepo / hrepoadd / hrepoup${RESET}   ${WHITE}Helm repos${RESET}"
    echo -e "  ${CYAN}vup / vssh / vhalt / vreload / vdestroy / vstatus / vsnap${RESET}   ${WHITE}Vagrant${RESET}"
    echo -e "  ${CYAN}aping / ai${RESET}   ${WHITE}Ansible ping / inventory${RESET}"
    echo ""

}
