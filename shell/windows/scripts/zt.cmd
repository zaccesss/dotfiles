@echo off
rem runs the PowerShell version of zt, so Command Prompt switches themes the same way
pwsh -NoLogo -NoProfile -File "%~dp0zt.ps1" %*
