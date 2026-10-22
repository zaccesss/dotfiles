# Security Policy

## Scope

This repository holds personal configs: shell profiles, bootstrap scripts, Git hooks, SSH and Git
config files, editor settings and themes. It contains no web service and no library. Issues in
scope include:

- Accidental inclusion of secrets, tokens, private keys or credentials in tracked files
- A real key, host entry or personal detail committed by mistake in the [ssh](git/ssh) or
  [gitconfig](git/gitconfig) folders
- A false negative in the [git-hooks](git/git-hooks) secret patterns
- A hook that silently fails to block what it claims to block
- Unsafe bootstrap behaviour: commands that could damage or compromise a machine
- Insecure handling of downloaded software and vendor package repositories
- Shell injection in a function, hook or script that handles a filename, argument or commit message
- A setting that weakens a security or privacy default without its reference saying so
- Setup instructions or installer scripts that leave insecure file permissions behind
- Functions that silently escalate privileges

## Token and key policy

No tokens, passwords, private keys or API keys are ever committed to this repository. Sensitive
values belong in a secrets file (chmod 600) or the OS keychain and are read at run time. The
[shell NOTICE](shell/NOTICE.md) lists the variables that must be treated this way. The ssh folder
ships placeholder public keys and an example signers file only. The root `.gitignore` blocks any
filename shaped like a private key under `git/ssh/`.

If you find a token or credential that was accidentally committed, please report it immediately so
it can be revoked and the history cleaned.

## Reporting a vulnerability

If you find a security issue in this repository, please do not open a public issue. Instead,
contact me via:

- Email: contact@isaacadjei.me
- Contact form: https://isaacadjei.me/contact

Please include:

- A description of the issue
- Which folder, file and function is affected
- A brief explanation of how it could be exploited

I will respond within 7 days and aim to publish a fix within 14 days of confirmation.

## Known limitations

Some shell helpers build commands from arguments without full sanitisation. This is intentional:
they are personal shell helpers, not public-facing utilities. Do not expose them over a network or
run them as root unless you understand what they do.

## The shared policy

> [!NOTE]
> The full policy, covering scope, the disclosure process and expected response times, is in [zaccesss/security-policy](https://github.com/zaccesss/security-policy) and on [my site](https://isaacadjei.me/security-policy). This file takes precedence where the two differ.
