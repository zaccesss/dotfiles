# =============================================================================
# Rust and Cargo
# =============================================================================

function cr     { cargo run $args }
function cb     { cargo build }
function cbr    { cargo build --release }
function ct     { cargo test }
function ccheck { cargo check }
function cfmt   { cargo fmt }
function cclean  { cargo clean }
function cinit   { cargo init }
function cadd    { param($Pkg) cargo add $Pkg }
function crm     { param($Pkg) cargo remove $Pkg }
function cupd    { cargo update }
function cdoc    { cargo doc --open }
function cbench  { cargo bench }
function cclippy { cargo clippy }
