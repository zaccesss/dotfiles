# temporary forwarding file: the real one moved to shell/. removed in a later release, once
# a machine has had time to re-run its bootstrap
& (Join-Path $PSScriptRoot '..\..\shell\windows\scripts\zt.ps1') @args
