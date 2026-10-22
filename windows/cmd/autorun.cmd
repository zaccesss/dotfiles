@echo off
rem temporary forwarding file: the real one moved to shell/. removed in a later release, once
rem a machine has had time to re-run its bootstrap
for %%I in ("%~dp0..\..\shell") do set "DOTFILES=%%~fI"
call "%DOTFILES%\windows\cmd\autorun.cmd"
rem the real start-up decides whether this window is interactive, so the notice follows it
if defined DOTFILES_CMD_INTERACTIVE if not defined DOTFILES_MOVED_SHOWN (
    echo dotfiles moved to shell/: run setup/windows-bootstrap to re-point
    set "DOTFILES_MOVED_SHOWN=1"
)
