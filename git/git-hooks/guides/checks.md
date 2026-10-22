# Check reference

Every check across the three hooks, what triggers it and what happens.

## commit-msg

### Blocked

| Check | Example that blocks |
| --- | --- |
| Subject line over 72 characters | A first line longer than 72 characters |

## pre-commit

### Blocked

| Check | Covers |
| --- | --- |
| Secret patterns | AWS access keys, GCP service account JSON, Google API keys and OAuth tokens, Azure identifiers, DigitalOcean tokens, GitHub tokens (classic and fine-grained), GitLab tokens, npm tokens, PyPI tokens, `.npmrc` auth tokens, Stripe live keys, Slack tokens, SendGrid, Twilio and Mailgun keys, Discord bot tokens, private key headers, database connection strings with an embedded password, JWT-shaped tokens, a variable named like a credential holding a long literal value |
| Large file, no LFS | Warns at 10MB, blocks at 50MB, unless the file matches a `filter=lfs` pattern in `.gitattributes` |
| `.env`-pattern file | Any `.env` or `.env.*` file, except one ending in `.example`, `.sample` or `.template` |

> [!TIP]
> This is a defence-in-depth layer, not a replacement for a real secret scanner. It only
> covers well-known, high-confidence token shapes. A proper scan (gitleaks or equivalent) run
> in CI is still the source of truth.

### Warned, does not block

- Committing while checked out directly on `main` or `master`, deliberately a warning rather
  than a block since not every repo uses a branch-per-change workflow, a hard block here would
  be disruptive on one where committing straight to main is the accepted pattern

## pre-push

### Blocked

- A force-push that would rewrite `main` or `master`'s history (detected by checking whether
  the remote commit is still an ancestor of the local one)

### Passthrough, unrelated to policy

- Git LFS's own `pre-push` hook runs afterward, for any repo that actually uses LFS

## Escape hatch

Every block above can be skipped for one operation:

```bash
git commit --no-verify
git push --no-verify
```

> [!CAUTION]
> Use this deliberately, after checking the diff yourself, not as a default habit. The whole
> point of these hooks is to catch the case where checking manually was skipped.
