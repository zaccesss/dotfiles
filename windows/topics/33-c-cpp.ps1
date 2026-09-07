# =============================================================================
# C and C++ - Windows PowerShell
# Uses MSVC (cl.exe) or clang (winget install LLVM.LLVM).
# MinGW gcc/g++ also work if on PATH.
# =============================================================================

# Use clang if available, fall back to cl.exe (MSVC)
function cc2 {
    param([string]$File, [string]$Out = ($File -replace "\.c$", ".exe"))
    if (Get-Command clang -ErrorAction SilentlyContinue) {
        clang -Wall -Wextra -o $Out $File
    } else {
        cl /W3 /Fe:$Out $File
    }
}

function ccrun {
    param([string]$File)
    $out = $File -replace "\.c$", ".exe"
    cc2 $File $out
    if (Test-Path $out) { & ".\$out"; Remove-Item $out }
}

function ccdbg {
    param([string]$File, [string]$Out = ($File -replace "\.c$", "_dbg.exe"))
    if (Get-Command clang -ErrorAction SilentlyContinue) {
        clang -g -Wall -Wextra -o $Out $File
    } else {
        cl /Zi /W3 /Fe:$Out $File
    }
}

# MSVC only supports the address sanitizer (no undefined-behaviour sanitizer)
function ccsan {
    param([string]$File, [string]$Out = ($File -replace "\.c$", "_san.exe"))
    if (Get-Command clang -ErrorAction SilentlyContinue) {
        clang -Wall -Wextra "-fsanitize=address,undefined" -o $Out $File
    } else {
        cl /fsanitize=address /W3 /Fe:$Out $File
    }
}

function cppc {
    param([string]$File, [string]$Out = ($File -replace "\.cpp$", ".exe"))
    if (Get-Command clang++ -ErrorAction SilentlyContinue) {
        clang++ -std=c++20 -Wall -Wextra -o $Out $File
    } else {
        cl /std:c++20 /W3 /Fe:$Out $File
    }
}

function cpprun {
    param([string]$File)
    $out = $File -replace "\.cpp$", ".exe"
    cppc $File $out
    if (Test-Path $out) { & ".\$out"; Remove-Item $out }
}

function cppdbg {
    param([string]$File, [string]$Out = ($File -replace "\.cpp$", "_dbg.exe"))
    if (Get-Command clang++ -ErrorAction SilentlyContinue) {
        clang++ -std=c++20 -g -Wall -Wextra -o $Out $File
    } else {
        cl /std:c++20 /Zi /W3 /Fe:$Out $File
    }
}

function cppsan {
    param([string]$File, [string]$Out = ($File -replace "\.cpp$", "_san.exe"))
    if (Get-Command clang++ -ErrorAction SilentlyContinue) {
        clang++ -std=c++20 -Wall -Wextra "-fsanitize=address,undefined" -o $Out $File
    } else {
        cl /std:c++20 /fsanitize=address /W3 /Fe:$Out $File
    }
}

function cfmt2 { param($File) clang-format -i $File }
function ctidy { clang-tidy @args }
function hd    { param($File) Format-Hex $File }

# Debugger and binutils - prefer LLVM tools (winget install LLVM.LLVM), fall back to MinGW
function dbg {
    if (Get-Command lldb -ErrorAction SilentlyContinue) { lldb @args } else { gdb @args }
}
function symbols {
    if (Get-Command llvm-nm -ErrorAction SilentlyContinue) { llvm-nm @args } else { nm @args }
}
function odump {
    if (Get-Command llvm-objdump -ErrorAction SilentlyContinue) { llvm-objdump @args } else { objdump @args }
}
function bsize {
    if (Get-Command llvm-size -ErrorAction SilentlyContinue) { llvm-size @args } else { size @args }
}
