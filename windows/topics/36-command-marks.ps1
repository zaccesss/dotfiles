# =============================================================================
# Command marks - OSC 133 shell integration
# Tells the terminal where each prompt, command and output starts and ends, so
# it can jump from one command to the next and select a single command's
# output. Windows Terminal reads these through its scrollToMark, selectCommand
# and selectOutput actions, which are bound in its own settings.json.
# Loaded after starship, so it wraps the prompt starship defines.
# =============================================================================

# a dumb terminal would print the escapes as text, a non-interactive run never shows a prompt
# and a host other than the console (the VS Code extension host, for one) draws its own.
# VS Code's terminal brings its own OSC 633 marks: VSCODE_INJECTION is set while it starts
# the shell and VSCODE_SHELL_INTEGRATION once its script has run
$cmdMarkSkip = ($env:TERM -eq 'dumb') -or
    $env:VSCODE_SHELL_INTEGRATION -or
    ($env:TERM_PROGRAM -eq 'vscode' -and $env:VSCODE_INJECTION) -or
    ($Host.Name -ne 'ConsoleHost') -or
    ([Environment]::GetCommandLineArgs() -match '^-noni') -or
    ($function:prompt -and $function:prompt.ToString().Contains('133;A'))

if (-not $cmdMarkSkip) {
    $global:CmdMarkInnerPrompt = $function:prompt
    $global:CmdMarkHistoryId = 0

    function global:prompt {
        $ok = $global:?
        $code = $global:LASTEXITCODE
        # VS Code's script runs after this profile, so it is checked again on every prompt
        $vscode = $env:VSCODE_SHELL_INTEGRATION -or (Test-Path variable:global:__VSCodeState)
        $marks = ''
        if (-not $vscode) {
            # D closes the last command with its status, only when one ran: an empty Enter
            # or Ctrl+C adds nothing to the history, so there is nothing to close
            $last = Get-History -Count 1
            if ($last -and $last.Id -ne $global:CmdMarkHistoryId) {
                $global:CmdMarkHistoryId = $last.Id
                # a native command's own exit code when it failed, otherwise 0 or 1 from $?
                $status = if ($ok) { 0 } elseif ($code) { $code } else { 1 }
                $marks = "`e]133;D;$status`a"
            }
            $marks += "`e]133;A`a"
        }

        # the wrapped prompt (starship) reads $LASTEXITCODE and $? to show the last status, so
        # both are put back first. Write-Error is the one way to set $? to false
        $global:LASTEXITCODE = $code
        if (-not $ok) { Write-Error '' -ErrorAction Ignore }
        $text = & $global:CmdMarkInnerPrompt

        if ($vscode) { $text } else { "$marks$text`e]133;B`a" }

        # leave $LASTEXITCODE and $? as the last command left them, this must stay the last step
        $global:LASTEXITCODE = $code
        if ($global:? -ne $ok) {
            if ($ok) { $null = 1 } else { Write-Error '' -ErrorAction Ignore }
        }
    }

    # C marks where a command's output starts, written as Enter accepts the line. an empty line
    # runs nothing, so it gets no mark
    if (Get-Module PSReadLine) {
        Set-PSReadLineKeyHandler -Chord Enter -BriefDescription AcceptLineWithMark -Description 'Accept the line and mark where its output starts' -ScriptBlock {
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
            if ($line.Trim() -and -not ($env:VSCODE_SHELL_INTEGRATION -or (Test-Path variable:global:__VSCodeState))) {
                [Console]::Write("`e]133;C`a")
            }
        }
    }
}

Remove-Variable cmdMarkSkip
