# =============================================================================
# Rust and Cargo
# All aliases use the 'c' prefix via cargo. I avoid 'cr' for 'cargo run'
# conflicting with anything since there's no standard 'cr' on macOS.
# =============================================================================

alias cr="cargo run"
alias cb="cargo build"
alias cbr="cargo build --release"
alias ct="cargo test"
alias ccheck="cargo check"
alias cfmt="cargo fmt"
alias cclean="cargo clean"
alias cinit="cargo init"
alias cadd="cargo add"
alias crm="cargo remove"
alias cupd="cargo update"
alias cdoc="cargo doc --open"
alias cbench="cargo bench"
alias cclippy="cargo clippy"            # linter
