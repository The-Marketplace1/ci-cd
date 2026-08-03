# Deployment Process

## Normal promotion path

The standard deployment flow is:

1. A change is merged into the `develop` branch.
2. CI, security, and Docker image build workflows complete successfully.
3. The immutable container image is deployed to the **Development** environment.
4. A reviewed change is merged into the `main` branch.
5. The **same commit** is built and deployed to **Staging**.
6. Staging health checks and smoke tests complete successfully.
7. GitHub Environment protection rules approve deployment to **Production**.
8. Amazon ECS completes its rolling update.
9. Production health checks and smoke tests verify the deployment.

> **Important:** The deployment workflow must use the immutable image produced by the Docker build workflow. Never replace SHA-based image tags with mutable tags such as `latest` for production deployments.

## Environment configuration

Each environment has its own:

- GitHub Environment
- Amazon ECS cluster
- Application variables
- Secrets

Use the corresponding file in the `environments/` directory as the **non-secret** configuration reference.

| Environment | Branch source | ECS cluster |
|-------------|---------------|-------------|
| **Development** | `develop` | `development-cluster` |
| **Testing** | Manual trigger or test caller | `testing-cluster` |
| **Staging** | `main` | `staging-cluster` |
| **Production** | Approved promotion from Staging | `production-cluster` |

## Migration behavior

Services with `run-migrations: true` execute their database migration task **before** Amazon ECS replaces the running service.

Migration changes must:

- Be backward compatible with the currently deployed application version.
- Use an **expand/contract** migration strategy.
- Avoid destructive schema changes during the same deployment.

## Deployment success

A deployment is considered successful only when all of the following conditions are met:

- Amazon ECS reports the service as stable.
- The configured health endpoint responds successfully.
- Any configured smoke tests complete successfully.

If deployment verification fails:

1. The rollback helper is executed.
2. A deployment failure notification is recorded and sent.