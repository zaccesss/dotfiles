# Reference

What every part of the setup does and why.

## `config`

```text
Host github.com
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Without `IdentitiesOnly yes`, SSH offers every key loaded in the agent to the server in turn. That
can trip a server's failed-attempt rate limit before it reaches the right key, especially with
several keys loaded. Pinning the identity per host avoids it. `gist.github.com` needs its own block
because SSH matches `Host` patterns literally, not by domain suffix.

```text
Host *
    AddKeysToAgent yes
    UseKeychain yes
```

`AddKeysToAgent yes` means a key's passphrase is only asked for once per agent session, not on
every `git` operation. `UseKeychain yes` (macOS only) persists that passphrase across reboots
through the system Keychain, instead of the agent forgetting it at every restart.

## `allowed_signers`

```text
you@example.com ssh-ed25519 <your-signing-public-key>
```

One line per signing key. This file is what `git log --show-signature` checks locally. It has
nothing to do with a forge's own server-side "Verified" badge, which is checked independently
against the public keys registered there. A machine missing from this file can still sign commits
that show as Verified on GitHub. `git log --show-signature` on another machine cannot confirm them
locally until that key's line is added.

## Why a separate signing key from the auth key

Using one key for both authentication and signing means a single compromised key grants push access
and the ability to forge a verified-looking commit. Splitting them means revoking one does not
require regenerating the other.

## Why public keys and known hosts are not included

Public keys are not secret, but they belong to you, so this folder ships an example instead of
anyone's real key. `known_hosts` is also left out and ignored: pin a forge's host key yourself with
`ssh-keyscan`, checked against the forge's own published fingerprint, rather than trusting a copy
from a repository.
