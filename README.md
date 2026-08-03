# Marketplace CI/CD

Reusable GitHub Actions pipelines, Docker build assets, deployment orchestration, security gates, release automation, and operational documentation for the Marketplace platform.

This repository deliberately contains automation only. Application source, Terraform state, runtime secrets, and production configuration remain in their respective service or infrastructure repositories.

## What is included

- Reusable CI workflows for Node.js backend services and frontend applications
- Flyway database migration checks and Terraform/Kubernetes/Helm validation
- Gitleaks, Trivy, CodeQL, and dependency license gates
- Multi-architecture Docker Buildx builds pushed to Amazon ECR
- ECS rolling deployment, health verification, smoke tests, and rollback
- Conventional Commit versioning, changelogs, Git tags, and GitHub releases
- Onboarding templates, example callers, policy documents, and runbooks

## Repository layout

```text
ci-cd/
├── .github/
│   ├── actions/              # Composite health, notification, and Docker actions
│   ├── ISSUE_TEMPLATE/       # Pipeline failure and service onboarding forms
│   └── workflows/
│       ├── reusable/         # workflow_call implementations
│       ├── backend/          # Backend service caller workflows
│       ├── frontend/         # Frontend application caller workflows
│       ├── database/         # Database migration caller
│       ├── infrastructure/   # IaC validation caller
│       ├── monitoring/       # Monitoring configuration caller
│       ├── security/         # Scheduled security audit
│       └── releases/         # Manual release caller
├── docker/                   # Reusable Node/frontend Docker assets and CI stack
├── scripts/                  # Build, test, deploy, release, health, smoke helpers
├── templates/                # New-service workflow templates
├── environments/             # Non-secret environment variable examples
├── policies/                 # Quality, security, secrets, dependency policies
├── docs/                     # Pipeline, deployment, release, rollback runbooks
└── examples/                 # Minimal caller workflow examples
```

## Installation model

GitHub discovers workflows only in a repository-root `.github/workflows` directory. Therefore, use one of these supported models:

### Marketplace monorepo

Copy the contents of this directory into the monorepo root so `.github/` is at the GitHub repository root. The provided service callers assume application paths such as `services/auth-service`.

### Central automation repository

Keep this repository dedicated to reusable workflows, then copy a caller from `templates/` or `examples/` into each application repository and reference the reusable workflow with:

```text
marketplace-org/ci-cd/.github/workflows/reusable/<workflow>.yml@<tag>
```

> **Do not** leave the directory nested under another repository and expect GitHub to discover its workflows automatically.

## Quick start

1. Create GitHub Environments: `development`, `testing`, `staging`, and `production`.
2. Configure the required AWS and Slack secrets listed in `policies/secrets-policy.md`.
3. Create ECR repositories, ECS clusters, ECS services, and task definitions.
4. Copy a workflow from `templates/` and replace all `__PLACEHOLDER__` values.
5. Check that service scripts match the reusable workflow contract:
   - `lint`
   - `format:check`
   - `typecheck`
   - `test:coverage`
   - `build`
6. Create a pull request and verify the CI and security gates.

See `docs/onboarding.md` for the complete process.

## Required secrets and variables

| Name | Type | Purpose |
|------|------|---------|
| `AWS_ACCESS_KEY_ID` | Secret | AWS delivery identity |
| `AWS_SECRET_ACCESS_KEY` | Secret | AWS delivery identity |
| `AWS_REGION` | Secret or variable | Target AWS region |
| `AWS_ACCOUNT_ID` | Secret or variable | AWS account used for ECR |
| `SLACK_WEBHOOK_URL` | Secret | Deployment/rollback notifications |
| `VITE_API_URL` | Environment variable | Frontend API base URL |
| `STAGING_URL` | Environment variable | Frontend E2E target URL |

> Prefer GitHub OIDC with short-lived AWS roles when available. Do not commit real values to files in `environments/`.

## Local checks

The scripts are intended for a Marketplace source checkout where service paths exist.

### Examples

```bash
bash scripts/build-all.sh --parallel
bash scripts/test-all.sh --coverage
bash scripts/health-check.sh --service auth-service --env staging
bash scripts/smoke-test.sh --url https://api.staging.marketplace.example.com
```

Start local test dependencies with:

```bash
docker compose -f docker/docker-compose.ci.yml up -d
```

## Operational guides

- Pipeline usage
- Deployment process
- Release process
- Rollback process
- Troubleshooting
- Service onboarding

## Security

Read **Security Policy** and **Secrets Policy** before adding a service. Do not report vulnerabilities in public issues.

## License

This project is distributed under the **MIT License**.