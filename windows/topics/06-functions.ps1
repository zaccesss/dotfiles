# =============================================================================
# Shell functions
# Core functions available on every Windows machine. refresh() is named
# differently from cls because cls is a built-in PowerShell alias for Clear-Host.
# =============================================================================

# mkcd: create a directory and cd into it in one step
function mkcd {
    param([string]$path)
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Set-Location $path
}

# refresh: hard-clear the terminal and reprint the welcome banner.
# Named refresh because cls is a built-in PS alias for Clear-Host.
# [System.Console]::Clear() clears the scrollback buffer; Clear-Host only clears the visible area.
function refresh {
    [System.Console]::Clear()
    Write-Host ""
    Write-Host $sep -ForegroundColor Cyan
    Write-Host "  🚀 Welcome back, Isaac!" -ForegroundColor Cyan
    Write-Host "  ✅ Windows profile loaded" -ForegroundColor Green
    Write-Host "  💻 $env:COMPUTERNAME - PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" -ForegroundColor Green
    Write-Host "  📅 $(Get-Date -Format 'ddd dd MMM yyyy  HH:mm')" -ForegroundColor Yellow
    Write-Host $sep -ForegroundColor Cyan
    Write-Host ""
}

# dot: pull the latest dotfiles and apply the Windows profile
function dot {
    $dotfilesPath = if ($env:DOTFILES) { $env:DOTFILES } else { "$HOME\dev\github\repos\dotfiles" }
    Write-Host "Pulling latest dotfiles..." -ForegroundColor Cyan
    git -C $dotfilesPath pull
    Write-Host "Applying Windows profile..." -ForegroundColor Cyan
    Copy-Item "$dotfilesPath\windows\Microsoft.PowerShell_profile.ps1" $PROFILE -Force
    . $PROFILE
    Write-Host "Done - dotfiles are up to date" -ForegroundColor Green
}


# List-Cmds: the live, raw counterpart to cmds() below. cmds() is a curated, hand-written
# cheat-sheet, this instead dumps every alias, function and PATH executable actually loaded
# right now, useful for checking what is really active rather than what the docs claim.
function List-Cmds {
  Write-Output "=== Aliases ==="
  Get-Alias | Format-Table -AutoSize
  Write-Output ""
  Write-Output "=== Functions ==="
  Get-Command -CommandType Function | Select-Object -Property Name
  Write-Output ""
  Write-Output "=== Executables in PATH (unique) ==="
  Get-Command -CommandType Application | Select-Object -ExpandProperty Source | Sort-Object -Unique
  Write-Output ""
  Write-Output "Inspect a command's details: Get-Command <name> -All"
}
Set-Alias lc List-Cmds

function _cmdsBody {
    ""
    "`e[36m=== Custom commands (type cmds to see this again, q to exit) ===`e[0m"
    "  `e[35mmagenta = category`e[0m   `e[36mcyan = commands`e[0m   `e[37mwhite = descriptions`e[0m"
    ""

    "`e[35mNAVIGATION`e[0m"
    "`e[36m  dev / downloads`e[0m"
    ""

    "`e[35mGIT`e[0m"
    "  `e[36mgs / ga / gaa / gcmt / gpsh / gcp / gpul`e[0m`e[37m   status/add/commit/push/pull`e[0m"
    "  `e[36mglog / gco / gcb / gb / gd`e[0m`e[37m           log/checkout/branch/diff`e[0m"
    "  `e[36mgundo / gbd / gclean`e[0m`e[37m                 undo/delete branch/clean`e[0m"
    "  `e[36mautomerge`e[0m`e[37m                            squash auto-merge the current PR and delete the branch`e[0m"
    ""

    "`e[35mREPOS`e[0m"
    "  `e[36mpull-all`e[0m`e[37m      pull all repos in C:\dev\github\repos`e[0m"
    "  `e[36mrepo-status`e[0m`e[37m   show branch and clean/dirty state for every repo`e[0m"
    ""

    "`e[35mSYSTEM`e[0m"
    "  `e[36mll / la`e[0m`e[37m         Get-ChildItem -Force (table / list)`e[0m"
    "  `e[36mmkcd`e[0m`e[37m            mkdir + cd in one step`e[0m"
    "  `e[36mrefresh`e[0m`e[37m         hard-clear terminal and reprint welcome banner`e[0m"
    "  `e[36mEdit-Profile`e[0m`e[37m    open profile in VS Code`e[0m"
    "  `e[36mReload-Profile`e[0m`e[37m  reload profile in current session`e[0m"
    "  `e[36mdot`e[0m`e[37m             pull latest dotfiles and apply them`e[0m"
    "  `e[36mcmds`e[0m`e[37m            show this command reference (q to exit)`e[0m"
    "  `e[36mlc / List-Cmds`e[0m`e[37m  dump every alias, function and PATH executable actually loaded`e[0m"
    ""

    "`e[35mUTILITIES`e[0m"
    "  `e[36mserve`e[0m`e[37m         python -m http.server 8080`e[0m"
    "  `e[36mpubip / myip`e[0m`e[37m  public IP shortcuts`e[0m"
    "  `e[36mweather`e[0m`e[37m       terminal weather from wttr.in`e[0m"
    "  `e[36mduh`e[0m`e[37m           disk usage sorted by size`e[0m"
    "  `e[36mpsgrep`e[0m`e[37m        search running processes by name`e[0m"
    ""

    "`e[35mCOMMUNITY TOOLS`e[0m"
    "  `e[36mextract`e[0m`e[37m           unpack any archive (zip, tar, 7z...)`e[0m"
    "  `e[36mtargz / gz`e[0m`e[37m        create .tar.gz / show compression ratio`e[0m"
    "  `e[36mdataurl`e[0m`e[37m           encode a file as a base64 data URL`e[0m"
    "  `e[36menvup`e[0m`e[37m             load a .env file into the current session`e[0m"
    "  `e[36mdigga`e[0m`e[37m             show all DNS records for a domain`e[0m"
    "  `e[36mdns-flush`e[0m`e[37m         ipconfig /flushdns`e[0m"
    "  `e[36mclipcopy / paste`e[0m`e[37m  Set-Clipboard / Get-Clipboard`e[0m"
    "  `e[36mchange-extension`e[0m`e[37m  batch rename extensions`e[0m"
    "  `e[36mGET / POST / PUT / DELETE / HEAD`e[0m`e[37m   Invoke-RestMethod HTTP shortcuts`e[0m"
    ""

    "`e[35mWINGET / CHOCOLATEY`e[0m"
    "  `e[36mwgup / wgins / wgrm / wgsearch / wgls / wginfo`e[0m`e[37m   winget`e[0m"
    "  `e[36mwgimport / wgexport`e[0m`e[37m   winget package import/export`e[0m"
    "  `e[36mchocoins / chocolist / chocoup / chocoinfo`e[0m`e[37m   Chocolatey`e[0m"
    ""

    "`e[35mSSH`e[0m"
    "  `e[36mnode1-4`e[0m`e[37m   ssh node1/node2/node3/node4 (cluster shortcuts)`e[0m"
    "  `e[36msshconf`e[0m`e[37m   open ~/.ssh/config in VS Code`e[0m"
    "  `e[36msshls`e[0m`e[37m     list loaded SSH keys (ssh-add -l)`e[0m"
    ""

    "`e[35mNETWORK`e[0m"
    "  `e[36mips / myip`e[0m`e[37m    list local IPs / public IP`e[0m"
    "  `e[36mopenports`e[0m`e[37m     listening ports`e[0m"
    "  `e[36mping4`e[0m`e[37m         ping -Count 4`e[0m"
    "  `e[36mspeedtest`e[0m`e[37m     run a network speed test`e[0m"
    "  `e[36mwh`e[0m`e[37m            whois`e[0m"
    "  `e[36mnginx-test / nginx-reload / nginx-restart`e[0m"
    ""

    "`e[35mSECURITY / CRYPTO`e[0m"
    "  `e[36msha256 / sha512`e[0m`e[37m   file checksums (Get-FileHash)`e[0m"
    "  `e[36mgpgls / gpglss / gpgenc / gpgdec / gpgsign / gpgverify`e[0m`e[37m   GPG`e[0m"
    ""

    "`e[35mDATABASE`e[0m"
    "  `e[36mpgls / pgdump / pgrestore / pgsize / pgusers`e[0m`e[37m   PostgreSQL`e[0m"
    "  `e[36mmyls / mydump`e[0m`e[37m   MySQL`e[0m"
    "  `e[36mmconn / mdbs`e[0m`e[37m    MongoDB (mongosh)`e[0m"
    "  `e[36mrcli / rping / rkeys / rinfo / rmon / rflush`e[0m`e[37m   Redis`e[0m"
    "  `e[36msq / influx`e[0m`e[37m   SQLite / InfluxDB`e[0m"
    ""

    "`e[35mJSON`e[0m"
    "  `e[36mjqk / jqf / jqlen / json-keys / json-min`e[0m"
    "`e[37m  (pretty-print / raw output / length / keys / minify)`e[0m"
    ""

    "`e[35mFILE SYNC (rclone)`e[0m"
    "  `e[36mrclonecopy / rclonesync / rcloneremotes / rls`e[0m"
    ""

    "`e[35mEDITORS`e[0m"
    "  `e[36me / ec`e[0m`e[37m        code . / code (VS Code)`e[0m"
    "  `e[36mextinstall / extls / extrm`e[0m`e[37m   VS Code extension management`e[0m"
    "  `e[36mnvimconf`e[0m`e[37m      open nvim config in VS Code`e[0m"
    ""

    "`e[35mSHELL TOOLS`e[0m"
    "  `e[36mshck`e[0m`e[37m                          shellcheck on .sh files (sc reserved for sc.exe)`e[0m"
    "  `e[36mpsanalyse / psanalysefix`e[0m`e[37m      PSScriptAnalyzer lint / autofix`e[0m"
    "  `e[36msfmt`e[0m`e[37m                          shfmt format`e[0m"
    ""

    "`e[35mWINDOWS TERMINAL / TMUX (via WSL)`e[0m"
    "  `e[36mwt-here`e[0m`e[37m       open Windows Terminal in current directory`e[0m"
    "  `e[36mwt-split`e[0m`e[37m      split current pane`e[0m"
    "  `e[36mtn / tls / tk / tka`e[0m`e[37m   WSL tmux new/list/kill-session/kill-server`e[0m"
    "  `e[36mcluster`e[0m`e[37m       open all 4 cluster nodes in a tmux layout (WSL)`e[0m"
    ""

    "`e[35mGITHUB CLI`e[0m"
    "  `e[36mghclone / ghfork / ghrepo / ghwho`e[0m"
    "  `e[36mghprc / ghprl / ghprv / ghprs / ghprco / ghprm`e[0m`e[37m   pull requests`e[0m"
    "  `e[36mghissc / ghissl / ghissv / ghissclose`e[0m`e[37m   issues`e[0m"
    "  `e[36mghrun / ghwatch / ghfail`e[0m`e[37m   workflow runs`e[0m"
    "  `e[36mghrls / ghrlsc`e[0m`e[37m   releases   |   `e[0m`e[36mghgist / ghgistc`e[0m`e[37m   gists`e[0m"
    ""

    "`e[35mNVM`e[0m"
    "  `e[36mnvmuse / nvmls / nvmls-remote / nvminstall / nvmdefault / nvmlts`e[0m"
    ""

    "`e[35mPYTHON`e[0m"
    "  `e[36mpy / pip / venv / activate / ptest / plint / pfmt / preqs`e[0m"
    "  `e[36mdjr / djm / djmm / djs / djc`e[0m`e[37m   Django manage.py`e[0m"
    ""

    "`e[35mJAVASCRIPT / NODE / TYPESCRIPT`e[0m"
    "  `e[36mnpmi / nid / nr / nd / nb / ns / nt / nlint / nfmt`e[0m"
    "`e[37m  (npmi = npm install, ni is New-Item in PowerShell)`e[0m"
    ""

    "`e[35mRUBY / RAILS`e[0m"
    "  `e[36mrb / irb`e[0m`e[37m   ruby / interactive REPL`e[0m"
    "  `e[36mbe / binst / bcheck / bupd / bclean`e[0m`e[37m   Bundler`e[0m"
    "  `e[36mrspec / rspecf / rubocop / rubofix`e[0m`e[37m   testing and linting`e[0m"
    "  `e[36mrs / rc / rd / rg / rrout`e[0m`e[37m   Rails server/console/migrate/generate/routes`e[0m"
    "  `e[36mrbinstall / rbls / rbuse / rbglobal`e[0m`e[37m   rbenv`e[0m"
    ""

    "`e[35mPHP / LARAVEL`e[0m"
    "  `e[36mpa / par / pat / pserve`e[0m`e[37m   artisan / serve / tinker / built-in server`e[0m"
    "  `e[36mpam / pamm / pamc / pamr / pamfs / pads`e[0m`e[37m   migrations and seeding`e[0m"
    "  `e[36mparl / paq / paoc`e[0m`e[37m   routes / queue / clear caches`e[0m"
    "  `e[36mci / cupdate / creq / cdump / coutdated`e[0m`e[37m   Composer`e[0m"
    "  `e[36mpunit / pint`e[0m`e[37m   PHPUnit / Laravel Pint`e[0m"
    ""

    "`e[35mGO`e[0m"
    "  `e[36mgor / gob / got / gfmt / govet / gomod`e[0m"
    ""

    "`e[35mRUST`e[0m"
    "  `e[36mcr / cb / cbr / ct / ccheck / cfmt / cclean`e[0m"
    ""

    "`e[35mJAVA / BUILD TOOLS`e[0m"
    "  `e[36mmvnt / mvnb / mvni / mvnc / mvncb`e[0m`e[37m   Maven`e[0m"
    "  `e[36mgwb / gwt / gwr / gwc / gwcb`e[0m`e[37m        Gradle wrapper`e[0m"
    ""

    "`e[35mC / C++`e[0m"
    "  `e[36mcc2 / ccrun / ccdbg / ccsan`e[0m`e[37m   compile / compile+run / debug build / sanitizers (C)`e[0m"
    "  `e[36mcppc / cpprun / cppdbg / cppsan`e[0m`e[37m   same, for C++ (C++20)`e[0m"
    "  `e[36mcfmt2 / ctidy`e[0m`e[37m   clang-format / clang-tidy`e[0m"
    "  `e[36mhd / odump / symbols`e[0m`e[37m   binary inspection`e[0m"
    ""

    "`e[35mDOCKER`e[0m"
    "  `e[36mdps / dpa / dex / dlogs / dstop / drm / dimg / dprune`e[0m"
    "  `e[36mdcu / dcud / dcd / dcb / dcl`e[0m`e[37m   Docker Compose`e[0m"
    ""

    "`e[35mKUBERNETES`e[0m"
    "  `e[36mkc / kg / ka / kd / klogs / kns / kctx / kpods`e[0m"
    ""

    "`e[35mCLOUD`e[0m"
    "  `e[36mawsls / awswho / awsec2 / awslambda`e[0m`e[37m   AWS`e[0m"
    "  `e[36mazls / azwho / azgroup / azweb`e[0m`e[37m   Azure`e[0m"
    "  `e[36mgcwho / gcfg / gcvms / gcrun / gcbuild`e[0m`e[37m   GCP`e[0m"
    ""

    "`e[35mDEVOPS / IaC`e[0m"
    "  `e[36mtfi / tfp / tfa / tfaa / tfd / tfda / tff / tfv`e[0m`e[37m   Terraform`e[0m"
    "  `e[36mtfs / tfo / tfst / tfw / tfwn / tfwsel`e[0m`e[37m   Terraform state/workspace`e[0m"
    "  `e[36mhinst / hup / hupi / hrm / hls / hlsa / hsearch / hvals / hdiff`e[0m`e[37m   Helm`e[0m"
    "  `e[36mhrepo / hrepoadd / hrepoup`e[0m`e[37m   Helm repos`e[0m"
    "  `e[36mvup / vssh / vhalt / vreload / vdestroy / vstatus / vsnap`e[0m`e[37m   Vagrant`e[0m"
    "  `e[36maping / ai`e[0m`e[37m   Ansible ping / inventory`e[0m"
    ""

}

# cmds: list all custom functions with short descriptions.
# Piped through Out-Host -Paging so real scrolling works on output this long and mouse-wheel
# scroll is handled by the pager itself instead of leaking through as arrow keys onto the
# prompt underneath. Press q to exit.
function cmds {
    _cmdsBody | Out-Host -Paging
}
