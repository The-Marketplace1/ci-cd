# Service Onboarding

## 1. Prepare the service

The service should provide:

- `package.json` and `pnpm-lock.yaml`
- Scripts for:
  - `lint`
  - `format:check`
  - `typecheck`
  - `test:coverage`
  - `build`
- A production-ready `Dockerfile`
- A no-auth health endpoint (typically `/health`)
- Test coverage output at `coverage/coverage-summary.json`

Frontend applications that include end-to-end testing should also provide:

- A Playwright configuration
- A Playwright command compatible with the frontend reusable workflow

## 2. Configure AWS

Create the following AWS resources:

- Amazon ECR repository
- Amazon ECS task definition family
- Amazon ECS service
- Target ECS clusters

> **Important:** The container name in the ECS task definition must match the `service-name` value passed to `cd-deploy.yml`.

If the service runs database migrations:

- Create an additional `<ecs-service>-migrate` task definition.
- Set `run-migrations: true` in the deployment workflow.

## 3. Configure GitHub

Configure the repository by completing the following steps:

- Create the four GitHub Environments:
  - Development
  - Testing
  - Staging
  - Production
- Add the required deployment secrets and non-secret variables.
- Protect the `main` branch and require successful CI and security checks.
- Require reviewers for the **Staging** and **Production** environments.
- Start from the appropriate workflow template in the `templates/` directory.

## 4. Add the caller workflow

Create the service workflow by:

- Copying and adapting `templates/service-ci-template.yml` for backend services, **or**
- Using the equivalent frontend caller pattern in `examples/frontend-app-example.yml`

Before committing:

- Replace every placeholder value.
- Configure dependency flags.
- Set the correct service path.

## 5. Validate

Verify the onboarding process by completing the following steps:

1. Open a pull request containing changes to the service.
2. Confirm that all CI and security checks pass.
3. Merge the changes into the `develop` branch.
4. Verify the deployment to the **Development** environment.
5. Promote a low-risk change through **Staging** before enabling **Production** deployments.

## Getting help

Use `.github/ISSUE_TEMPLATE/service-onboarding.md` to request infrastructure or Platform Engineering assistance during onboarding.