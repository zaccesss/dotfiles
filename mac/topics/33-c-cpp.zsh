# =============================================================================
# C and C++
# Low-level shortcuts for compiling/running/debugging C/C++ code.
# These are for quick single-file compilation, not project-scale builds.
# Requires: clang from Xcode or brew install gcc
# =============================================================================

# ─── C ───────────────────────────────────────────────────────────────────────

# cc2: compile a C file (avoids shadowing the system cc)
cc2() { clang -Wall -Wextra -o "${2:-${1%.c}}" "${1:?Usage: cc2 <file.c>}"; }

# ccrun: compile and run a C file, then clean up the binary
ccrun() {
    local src="${1:?Usage: ccrun <file.c>}"
    local out="${src%.c}"
    clang -Wall -Wextra -o "$out" "$src" && "./$out"
    rm -f "$out"
}

# ccdbg: compile with debug symbols for use with lldb/gdb
ccdbg() { clang -g -Wall -Wextra -o "${2:-${1%.c}_dbg}" "${1:?}"; }

# ccsan: compile with address and undefined-behaviour sanitizers (great for finding bugs)
ccsan() { clang -Wall -Wextra -fsanitize=address,undefined -o "${2:-${1%.c}_san}" "${1:?}"; }

# ─── C++ ─────────────────────────────────────────────────────────────────────

# cppc: compile a .cpp file
cppc() { clang++ -std=c++20 -Wall -Wextra -o "${2:-${1%.cpp}}" "${1:?Usage: cppc <file.cpp>}"; }

# cpprun: compile and run a .cpp file
cpprun() {
    local src="${1:?Usage: cpprun <file.cpp>}"
    local out="${src%.cpp}"
    clang++ -std=c++20 -Wall -Wextra -o "$out" "$src" && "./$out"
    rm -f "$out"
}

# cppdbg: compile C++ with debug symbols
cppdbg() { clang++ -std=c++20 -g -Wall -Wextra -o "${2:-${1%.cpp}_dbg}" "${1:?}"; }

# cppsan: compile C++ with sanitizers
cppsan() { clang++ -std=c++20 -Wall -Wextra -fsanitize=address,undefined -o "${2:-${1%.cpp}_san}" "${1:?}"; }

# ─── Shared tools ────────────────────────────────────────────────────────────

# lldb: start the debugger on a compiled binary
alias dbg="lldb"

# clang-format: format a C/C++ file in place
alias cfmt2="clang-format -i"

# clang-tidy: static analysis on a file
alias ctidy="clang-tidy"

# nm: list symbols in an object file or binary
alias symbols="nm -gU"

# objdump shortcut (uses llvm-objdump on mac)
alias odump="objdump"

# hexdump: dump a file as hex
alias hd="hexdump -C"

# size: show the section sizes of a compiled binary (useful for embedded targets)
alias bsize="size"
