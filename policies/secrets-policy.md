# Secrets Management Policy

## Never commit secrets

Never commit any of the following to the repository:

- API keys
- Passwords
- Connection strings
- Private keys
- OAuth tokens
- Signing material
- `.env` files containing real values
- Signed URLs

Use the example environment files as **variable-name references only**.

Gitleaks runs on every applicable workflow and scans both the current codebase and Git history. Any detected secret must be treated as **exposed**, even if the commit is later removed.

## Approved storage

Store delivery credentials in **GitHub Actions Secrets**, using the narrowest appropriate scope:

- **Environment secrets** for values that differ between environments
- **Repository secrets** for service-specific credentials
- **Organization secrets** only for intentionally shared credentials

Store non-sensitive configuration in **GitHub Actions Variables**.

For runtime application secrets:

- Use the platform-approved **AWS Secrets Manager** service.
- Inject secrets through **Amazon ECS task definitions**.
- **Do not** pass secrets as Docker image build arguments.

## Required secret names

| Secret | Purpose |
|---------|---------|
| `AWS_ACCESS_KEY_ID` | AWS deployment identity |
| `AWS_SECRET_ACCESS_KEY` | AWS deployment identity |
| `AWS_REGION` | AWS deployment region (when stored as a secret rather than a variable) |
| `AWS_ACCOUNT_ID` | AWS account identifier (when stored as a secret rather than a variable) |
| `SLACK_WEBHOOK_URL` | Deployment and rollback notifications |
| `GITHUB_TOKEN` | Automatically provided by GitHub Actions |

> **Recommendation:** Use OpenID Connect (OIDC) with short-lived AWS roles whenever organizational policy permits. This is preferred over long-lived AWS access keys.

## Rotation and incident response

Rotate delivery credentials:

- At least every **90 days**
- Immediately after any suspected or confirmed exposure

When a secret leak is discovered:

1. Revoke or rotate the affected secret immediately.
2. Identify all affected systems, services, and deployments.
3. Remove the exposed secret from the repository and workflow logs where possible.
4. Rerun all relevant security scans.
5. Record the incident according to the security team's incident response procedure.