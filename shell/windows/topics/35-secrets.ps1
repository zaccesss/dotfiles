# =============================================================================
# Secrets encryption - age and sops
# For actually committing a secret safely, encrypted, rather than the chmod 600
# file approach in NOTICE.md. Install:
#   winget install FiloSottile.age Mozilla.sops
# =============================================================================

# agenew: generate a new age keypair, saved where age itself looks by default
function agenew {
    New-Item -ItemType Directory -Force -Path "$HOME\.config\age" | Out-Null
    age-keygen -o "$HOME\.config\age\keys.txt"
}

# agenc: encrypt a file to <file>.age using a recipient's public key
function agenc {
    param([Parameter(Mandatory)][string]$File, [Parameter(Mandatory)][string]$Recipient)
    age -e -r $Recipient -o "$File.age" $File
}

# agedec: decrypt a <file>.age back to its original name, using the local private key
function agedec {
    param([Parameter(Mandatory)][string]$File)
    $out = $File -replace '\.age$', ''
    age -d -i "$HOME\.config\age\keys.txt" -o $out $File
}

# sopsenc: encrypt a file in place with sops (age backend via SOPS_AGE_KEY_FILE)
function sopsenc { param([Parameter(Mandatory)][string]$File) sops -e -i $File }

# sopsdec: decrypt a file in place with sops
function sopsdec { param([Parameter(Mandatory)][string]$File) sops -d -i $File }

# sopsedit: open an encrypted file in $EDITOR, decrypted while editing,
# re-encrypted automatically on save
function sopsedit { param([Parameter(Mandatory)][string]$File) sops $File }

# sopsview: print a decrypted file to stdout without writing anything to disk
function sopsview { param([Parameter(Mandatory)][string]$File) sops -d $File }
