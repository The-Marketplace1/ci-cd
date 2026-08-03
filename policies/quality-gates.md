# Quality Gates Policy

Every pull request and deployment must pass the applicable gates below. A failure blocks progression to the next pipeline stage. Bypasses require a documented exception approved by the Platform Engineering owner.

## Backend services

| Gate | Requirement |
|------|-------------|
| **Install** | `pnpm install --frozen-lockfile` completes successfully |
| **Linting** | Lint and formatting checks pass |
| **Type safety** | `typecheck` passes with no errors |
| **Unit tests** | All tests pass |
| **Coverage** | At least **80%** line coverage by default |
| **Build** | Production build completes |
| **Dependencies** | No **HIGH** or **CRITICAL** Trivy findings |
| **Container** | Docker image builds successfully |

> **Additional requirements**
>
> - Authentication services require **at least 85%** code coverage.
> - Payment services require **at least 90%** code coverage and use the strictest secret-scanning and CodeQL checks.

## Frontend applications

Frontend applications use the same install, lint, typecheck, test, build, and security gates.

- Default coverage threshold: **75%**
- Customer and Professional applications additionally run **Playwright E2E** checks on the `main` branch.

## Database changes

Database pipeline gates require:

- PostgreSQL-compatible SQL linting
- Migration names in the `VYYYYMMDDHHMMSS__description.sql` format
- No duplicate migration versions
- One rollback script for each migration
- A successful **Flyway** migrate, rollback, and re-migrate sequence

## Infrastructure changes

Infrastructure changes must pass:

- Terraform formatting (`terraform fmt`)
- Terraform validation
- Terraform plan
- Strict Kubernetes manifest validation
- Helm lint
- Helm template rendering

> **Note:** The pipeline validates infrastructure only. It never applies infrastructure changes.

## Release and deployment gates

Before a release or deployment proceeds:

- The originating CI and security workflows must be successful.
- The container image must exist in Amazon ECR and be identified by its immutable SHA tag.
- Deployment must complete Amazon ECS stability checks.
- The application's health endpoint and configured smoke tests must pass.
- Production deployments require approval from the GitHub **production** environment.

## Exceptions

Document any approved exception in the pull request, including:

- Failed gate
- Business justification
- Risk owner
- Mitigation plan
- Expiration date

> Exceptions **do not** apply to:
>
> - Secret exposure
> - Critical production vulnerabilities