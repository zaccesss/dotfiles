# =============================================================================
# Node version manager - Windows uses nvm-windows or fnm
# nvm-windows: https://github.com/coreybutler/nvm-windows
# fnm (faster): winget install Schniz.fnm
# =============================================================================

# nvm-windows shortcuts
function nvmuse        { nvm use @args }
function nvmls         { nvm list }
function nvmls-remote  { nvm list available }
function nvminstall    { param($Version) nvm install $Version }
function nvmuninstall  { param($Version) nvm uninstall $Version }
function nvmcurrent    { nvm current }
function nvmdefault    { param($Version) nvm use $Version }
function nvmlts        { nvm install lts && nvm use lts }

# fnm shortcuts (if using fnm instead of nvm-windows)
function fnmuse        { fnm use @args }
function fnmls         { fnm list }
function fnmls-remote  { fnm list-remote }
function fnminstall    { param($Version) fnm install $Version }
function fnmuninstall  { param($Version) fnm uninstall $Version }
function fnmcurrent    { fnm current }
function fnmdefault    { param($Version) fnm default $Version }
function fnmlts        { fnm install --lts && fnm use lts-latest }
