@echo off
rem temporary forwarding file: the real one moved to shell/. removed in a later release, once
rem a machine has had time to re-run its bootstrap
for %%I in ("%~dp0..\..\shell") do set "DOTFILES=%%~fI"
call "%DOTFILES%\windows\scripts\zacess-theme.cmd" %*
