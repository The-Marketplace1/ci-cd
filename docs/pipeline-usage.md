# Pipeline Usage

## Trigger behavior

Service and frontend caller workflows run on:

- Pull requests
- Pushes to the `develop` branch
- Pushes to the `main` branch

Workflows are triggered only when files under the service's configured path change.

### Pull requests

- Run CI and security gates.

### Pushes to `develop`

- Build the container image.
- Deploy to the **Development** environment.

### Pushes to `main`

- Build the container image.
- Deploy to **Staging**.
- Deploy to **Production** after GitHub Environment protection rules approve the promotion.

Database, infrastructure, monitoring, security, and release pipelines are implemented as separate caller workflows under `.github/workflows/`.

## Reusable workflow catalog

| Workflow | Purpose |
|----------|---------|
| `reusable/ci-backend.yml` | Install, lint, typecheck, test, coverage, build, and Docker validation |
| `reusable/ci-frontend.yml` | Frontend quality checks with optional Playwright E2E tests |
| `reusable/ci-database.yml` | SQL validation, migration checks, rollback validation, and Flyway verification |
| `reusable/ci-infrastructure.yml` | Terraform, Kubernetes, and Helm validation |
| `reusable/security-scan.yml` | Gitleaks, Trivy, CodeQL, and license checks |
| `reusable/docker-build-push.yml` | Docker Buildx build, Amazon ECR push, image scan, and build cache |
| `reusable/cd-deploy.yml` | Amazon ECS deployment, migrations, health checks, smoke tests, and rollback |
| `reusable/cd-rollback.yml` | Amazon ECS rollback with post-rollback verification |
| `reusable/release.yml` | Semantic versioning, changelog generation, Git tagging, and GitHub Releases |

## Calling a workflow

Reference reusable workflows with `uses` at the **job level**.

If the reusable workflow requires GitHub Actions or AWS credentials, pass:

```yaml
secrets: inherit
```

Example:

```yaml
jobs:
  ci:
    uses: ./.github/workflows/reusable/ci-backend.yml
    with:
      service-name: orders-service
      service-path: services/orders-service
      coverage-threshold: 80
    secrets: inherit
```

See the files in the `examples/` and `templates/` directories for complete workflow configurations.

## Required GitHub setup

Configure the repository before using these workflows:

- Create the following GitHub Environments:
  - Development
  - Testing
  - Staging
  - Production
- Restrict **Staging** and **Production** deployments with required reviewers.
- Configure the AWS and notification secrets documented in `policies/secrets-policy.md`.
- Grant workflows only the minimum permissions they require.

The Docker image build workflow template includes the following permissions:

- `contents: read`
- `id-token: write`
- `security-events: write`