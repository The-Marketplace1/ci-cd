# Dependency Policy

## Approved sources

Use dependencies from official package registries and maintained publishers. Pin application dependencies with `pnpm-lock.yaml` and install in CI with:

```bash
pnpm install --frozen-lockfile
```

Do not add a package when a maintained standard library or existing project dependency already meets the need. New dependencies should have:

- An active maintainer
- A documented security history
- A compatible license
- A clear owner within the service team

## Vulnerability controls

Trivy scans dependencies for **HIGH** and **CRITICAL** findings.

- **Critical** findings block merges and releases.
- **High** findings block releases unless an approved, time-limited exception documents why an upgrade or mitigation cannot ship immediately.

Do **not** resolve a vulnerability by:

- Disabling a scanner
- Ignoring an entire package family
- Downgrading a lockfile without a documented reason

## License allowlist

The automated license check permits:

- MIT
- ISC
- Apache-2.0
- BSD-2-Clause
- BSD-3-Clause
- CC0-1.0
- 0BSD
- Unlicense
- Python-2.0

Any other license requires legal and platform-owner approval before it may be merged. Copyleft licenses are **not approved by default**.

## Update cadence

- Review routine dependency updates weekly.
- Patch critical vulnerabilities immediately.
- Patch high vulnerabilities within the agreed security remediation window.
- Keep base images on supported Node, Nginx, PostgreSQL, and Redis releases.