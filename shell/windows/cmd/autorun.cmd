@echo off
rem Command Prompt start-up, run through the AutoRun value under
rem HKCU\Software\Microsoft\Command Processor, which the Windows bootstrap sets.
rem cmd.exe runs AutoRun for every instance, including the ones scripts and
rem programs start with /c or /k, so everything below is skipped for those and
rem only an interactive window gets the prompt, macros and banner.

setlocal EnableDelayedExpansion
set "interactive=1"
set "line=!CMDCMDLINE!"
if /i not "!line:/c =!"=="!line!" set "interactive="
if /i not "!line:/k =!"=="!line!" set "interactive="
endlocal & set "DOTFILES_CMD_INTERACTIVE=%interactive%"
if not defined DOTFILES_CMD_INTERACTIVE goto :eof

rem a window opened before the shell/ move can pass on DOTFILES naming the clone's root. that root
rem keeps a stand-in autorun.cmd but no macros, so only a value with shell/'s macros.doskey counts
if defined DOTFILES if not exist "%DOTFILES%\windows\cmd\macros.doskey" set "DOTFILES="
if not defined DOTFILES for %%I in ("%~dp0..\..") do set "DOTFILES=%%~fI"

rem every PowerShell alias and short function that is a plain command line,
rem written by scripts/build-cmd-macros.py
doskey /macrofile="%~dp0macros.doskey"

rem $E[3xm picks one of the terminal's own 16 colours rather than a fixed one,
rem so the prompt follows whatever theme the terminal is on, dark or light:
rem user@machine in cyan, the folder in yellow, then > in green on its own line
prompt $E[1;36m%USERNAME%@%COMPUTERNAME%$E[0m $E[1;33m$P$E[0m$_$E[1;32m$G$E[0m$S

rem the same banner as the PowerShell profile; set DOTFILES_NO_BANNER to skip it
if not defined DOTFILES_NO_BANNER (
    where pwsh >nul 2>nul && pwsh -NoLogo -NoProfile -File "%~dp0banner.ps1"
)
