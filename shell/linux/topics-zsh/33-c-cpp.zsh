# =============================================================================
# C and C++ - Linux uses gcc/g++ by default
# Requires: apt install gcc g++ clang
# =============================================================================

cc2() { gcc -Wall -Wextra -o "${2:-${1%.c}}" "${1:?Usage: cc2 <file.c>}"; }

ccrun() {
    local src="${1:?Usage: ccrun <file.c>}"
    local out="${src%.c}"
    gcc -Wall -Wextra -o "$out" "$src" && "./$out"
    rm -f "$out"
}

ccdbg() { gcc -g -Wall -Wextra -o "${2:-${1%.c}_dbg}" "${1:?}"; }
ccsan() { gcc -Wall -Wextra -fsanitize=address,undefined -o "${2:-${1%.c}_san}" "${1:?}"; }

cppc() { g++ -std=c++20 -Wall -Wextra -o "${2:-${1%.cpp}}" "${1:?Usage: cppc <file.cpp>}"; }

cpprun() {
    local src="${1:?Usage: cpprun <file.cpp>}"
    local out="${src%.cpp}"
    g++ -std=c++20 -Wall -Wextra -o "$out" "$src" && "./$out"
    rm -f "$out"
}

cppdbg() { g++ -std=c++20 -g -Wall -Wextra -o "${2:-${1%.cpp}_dbg}" "${1:?}"; }
cppsan() { g++ -std=c++20 -Wall -Wextra -fsanitize=address,undefined -o "${2:-${1%.cpp}_san}" "${1:?}"; }

alias dbg="gdb"
alias cfmt2="clang-format -i"
alias ctidy="clang-tidy"
alias symbols="nm -gU 2>/dev/null || nm -g"
alias odump="objdump -d -M intel"
alias hd="hexdump -C"
alias bsize="size"

# memcheck: valgrind is Linux-only here - no Apple Silicon support and no Windows build
alias memcheck="valgrind --leak-check=full"
