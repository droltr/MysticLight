# Contributing

Thank you for helping improve this project. Changes should remain reviewable,
reproducible, and safe for the supported hardware.

## Before starting

- Search existing issues and pull requests before opening a duplicate.
- Use a security advisory rather than a public issue for vulnerabilities or
  accidentally exposed identifiers. See [SECURITY.md](SECURITY.md).
- Open an issue before work that changes hardware communication, service
  behavior, repository architecture, or supported devices.

## Branches

The `main` branch represents the latest reviewed, working state. Do not commit
feature work directly to it. Create a short-lived branch from an up-to-date
`main` branch:

```bash
git switch main
git pull --ff-only
git switch -c <type>/<short-description>
```

Use one of these prefixes: `feature/`, `fix/`, `docs/`, `test/`, `security/`,
or `chore/`. Keep each branch focused on one concern and delete it after the
pull request is merged.

## Commits and pull requests

- Write imperative commit subjects, for example `Redact hardware identifiers`.
- Reference the related issue with `Closes #123` when appropriate.
- Explain user-visible behavior, safety impact, testing, and rollback steps.
- Open risky or incomplete hardware changes as draft pull requests.
- Require passing checks and at least one review before merge.
- Prefer squash merge for a small iterative branch; preserve individual
  commits when each commit is independently meaningful.

## Validation

Before requesting review, run:

```bash
bash -n scripts/*.sh
python3 -m unittest discover -s game-lighting/tests -v
git diff --check
```

Do not run experimental hardware writes as part of automated tests. Physical
tests must identify the tested zone and expected effect without publishing a
unique device identifier.

## Sensitive data

Before committing logs or screenshots, remove device serial numbers,
usernames, hostnames, home-directory paths, IP and MAC addresses, tokens, and
other stable identifiers. Configuration files containing local values or
credentials must remain untracked.

If sensitive data is committed, stop sharing it, notify the maintainer
privately, rotate any credential that can be rotated, and clean the reachable
Git history before continuing normal development.
