# Troubleshooting CI/CD

## A workflow does not appear in GitHub Actions

GitHub only discovers workflow files located at:

```text
.github/workflows/
```

in the repository root.

If this automation repository is consumed by another repository:

- Copy the required caller workflow into the consumer repository.
- Ensure the workflow exists in the consumer repository's root-level `.github/workflows/` directory.

## `pnpm install --frozen-lockfile` fails

Do **not** remove `--frozen-lockfile` in CI.

Resolve the issue by:

1. Running the package manager locally using the required `pnpm` version.
2. Updating `pnpm-lock.yaml`.
3. Committing the updated lockfile.
4. Rerunning the workflow.

## Coverage gate fails

When coverage validation fails:

1. Open the uploaded coverage artifact.
2. Identify changed code without sufficient test coverage.
3. Add or improve tests.
4. Rerun the pipeline.

> Do **not** lower a coverage threshold only to merge a feature.

## Docker build cannot push to ECR

Verify the following:

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` are available to the workflow, or replace them with an approved OIDC role.
- The Amazon ECR repository exists and matches the configured `service-name`.
- The deployment role can obtain an ECR authorization token.
- The deployment role has permission to push container images.

## ECS deployment does not stabilize

Investigate:

- ECS service events
- Stopped task reasons
- CloudWatch logs
- Task definition environment variables
- Security group connectivity

After identifying the cause:

- Correct the issue and deploy a new immutable image, or
- Perform a manual rollback.

## Health check fails

Verify that:

- The service `/health` endpoint is available without authentication.
- The configured hostname matches the target environment.
- The endpoint returns success only after required dependencies are ready.
- `health-check-path` is overridden when a service uses a different health endpoint.

## Security scanner fails

Treat the following as release blockers:

- Detected secrets
- HIGH vulnerabilities
- CRITICAL vulnerabilities

Required actions:

1. Rotate exposed secrets immediately.
2. Follow the applicable security policy for false positives or accepted risks.
3. Document any approved, time-bound exception.

> Do **not** disable security scanners globally.

## Release cannot create a tag

Confirm that:

- The workflow has `contents: write` permission.
- Branch or tag protection rules allow the GitHub Actions bot to create tags.
- A tag with the calculated service version does not already exist.