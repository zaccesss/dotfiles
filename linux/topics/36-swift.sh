# =============================================================================
# Swift on Linux
# Swiftly provides the Swift toolchain. Keep its binaries after system tools
# so Ubuntu's GCC, Clang and LLDB remain the default development tools.
# =============================================================================

if [[ -d "$HOME/.local/share/swiftly/bin" ]]; then
    export PATH="$PATH:$HOME/.local/share/swiftly/bin"
fi

alias sr="swift run"
alias sb2="swift build"
alias sb2r="swift build -c release"
alias st2="swift test"
alias srepl="swift repl"
alias sflint="swiftlint"

alias spinit="swift package init"
alias spinite="swift package init --type executable"
alias spinitl="swift package init --type library"
alias spup="swift package update"
alias spres="swift package resolve"
alias spls="swift package show-dependencies"
alias spclean="swift package clean"

alias swift-version="swift --version"
