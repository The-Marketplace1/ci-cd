# Security Policy

## Reporting a vulnerability

Do **not** open a public issue for a suspected security vulnerability.

Report vulnerabilities to the Marketplace Security Team through the organization's approved **private security reporting channel**.

Include the following information:

- Affected service
- Security impact
- Steps to reproduce
- Suggested remediation (if available)

## Pipeline controls

This repository enforces the following security controls:

- **Gitleaks** scans the complete Git history for credentials, secrets, and private keys.
- **Trivy** scans source dependencies and published container images for **HIGH** and **CRITICAL** vulnerabilities.
- **CodeQL** runs the security-and-quality query suite for supported services.
- **License checks** permit only licenses approved by the Dependency Policy.
- **Weekly security audits** perform scheduled scans independent of code changes.

## Severity handling

| Severity | Required action |
|----------|-----------------|
| **Critical** | Block deployment. Rotate exposed credentials immediately and remediate before release. |
| **High** | Block deployment unless the Security Owner approves a documented, time-bound exception. |
| **Medium** | Create a remediation work item and resolve it during the next planned maintenance cycle. |
| **Low** | Track and remediate when practical. |

## Secure delivery requirements

The following requirements apply to all deployments:

- Use immutable container image tags based on the commit SHA.
- Deploy only through GitHub Actions.
- Do **not** perform manual Amazon ECS changes except during an active incident, and reconcile any emergency changes afterward.
- Use protected GitHub Environments for **staging** and **production**.
- Grant each GitHub Environment only the credentials it requires.
- Keep production credentials out of local `.env` files and repository content.

## Security scan failures

Treat all security scan failures as **release blockers**.

If a security scanner is unavailable:

1. Do **not** silently skip the scan.
2. Fail the pipeline.
3. Investigate and resolve the tooling outage.
4. Rerun the workflow after the scanning service has been restored.