# =============================================================================
# Secrets encryption - age and sops
# For actually committing a secret safely, encrypted, rather than the chmod 600
# file approach in NOTICE.md. Install (Debian/Ubuntu):
#   sudo apt install age; sudo snap install sops (or download from GitHub releases)
# =============================================================================

# agenew: generate a new age keypair, saved where age itself looks by default
agenew() {
    mkdir -p "$HOME/.config/age"
    age-keygen -o "$HOME/.config/age/keys.txt"
}

# agenc: encrypt a file to <file>.age using a recipient's public key
agenc() {
    local file="${1:?Usage: agenc <file> <recipient-public-key>}" recipient="${2:?}"
    age -e -r "$recipient" -o "${file}.age" "$file"
}

# agedec: decrypt a <file>.age back to its original name, using the local private key
agedec() {
    local file="${1:?Usage: agedec <file.age>}"
    age -d -i "$HOME/.config/age/keys.txt" -o "${file%.age}" "$file"
}

# sopsenc: encrypt a file in place with sops (age backend via SOPS_AGE_KEY_FILE)
sopsenc() { sops -e -i "${1:?Usage: sopsenc <file>}"; }

# sopsdec: decrypt a file in place with sops
sopsdec() { sops -d -i "${1:?Usage: sopsdec <file>}"; }

# sopsedit: open an encrypted file in $EDITOR, decrypted while editing,
# re-encrypted automatically on save
sopsedit() { sops "${1:?Usage: sopsedit <file>}"; }

# sopsview: print a decrypted file to stdout without writing anything to disk
sopsview() { sops -d "${1:?Usage: sopsview <file>}"; }
