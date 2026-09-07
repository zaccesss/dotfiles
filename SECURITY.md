# Security Policy

## Scope

This is a personal dotfiles repository. It contains shell configuration, aliases
and helper functions. It does not contain application code, a web service or a
library, so the attack surface is narrow. Security issues that fall within scope
are:

- Accidental inclusion of secrets, tokens or credentials in tracked files
- Shell injection vulnerabilities in function arguments
- Insecure file permissions set by installer scripts
- Functions that silently escalate privileges

## Token policy

No tokens, passwords or API keys should ever be committed to this repository.
All sensitive values must be stored in a secrets file (chmod 600) or in the
OS keychain and sourced at runtime. See [NOTICE](NOTICE.md) for the full list of variables
that must be treated this way.

If you find a token or credential that was accidentally committed, please report
it immediately so it can be revoked and the history cleaned.

## Reporting a vulnerability

If you find a security issue in this repository, please do not open a public
issue. Instead, contact me via:

- Email: contact@isaacadjei.me
- Contact form: https://isaacadjei.me/contact

Please include:

- A description of the issue
- Which file and function is affected
- A brief explanation of how it could be exploited

I will respond within 7 days and aim to publish a fix within 14 days of
confirmation.

## Known limitations

Some functions in this repository execute shell commands built from user-supplied
arguments without full sanitisation. This is intentional - these are personal
shell helpers, not public-facing utilities. Do not expose them over a network or
run them as root unless you understand what they do.

## The shared policy

> [!NOTE]
> The full policy, covering scope, the disclosure process and expected response times, is in [zaccesss/security-policy](https://github.com/zaccesss/security-policy) and on [my site](https://isaacadjei.me/security-policy). This file takes precedence where the two differ.
