# Security Policy

## Supported versions

Security fixes are applied to the current `main` branch. Historical commits,
local deployment copies, and upstream submodules are not independently
supported by this repository.

## Reporting a vulnerability

Do not disclose vulnerabilities, credentials, unique hardware identifiers, or
unredacted diagnostic logs in a public issue.

Use GitHub's **Report a vulnerability** option in the repository's Security
tab to open a private security advisory. Include the affected revision, a
minimal reproduction, impact, and any known mitigation. If private reporting
is unavailable, open a public issue containing no sensitive or exploitable
details and ask the maintainer for a private contact channel.

You should receive an acknowledgement within seven days. Valid reports will
be assessed, fixed on a private branch when appropriate, and disclosed after
a remediation is available.

## Scope and safety

This project controls hardware through OpenRGB. Treat unverified HID, SMBus,
and I2C writes as potentially destructive. Reports involving OpenRGB or a
pinned plugin should also be coordinated with the relevant upstream project.

Public diagnostics must be redacted. At minimum, remove serial numbers,
usernames, hostnames, filesystem paths, network addresses, and access tokens.
