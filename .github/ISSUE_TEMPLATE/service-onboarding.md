---
name: New Service Onboarding
about: Request CI/CD pipeline setup for a new repository
title: "🚀 CI/CD Onboarding: [repository-name]"
labels: "[onboarding, ci-cd]"
assignees: []
---

# New Service Onboarding

## Repository Information

| Field | Value |
|-------|-------|
| Repository name | |
| Repository type | Backend Service / Frontend App / Database / Infrastructure / Other |
| Primary language | TypeScript / JavaScript / Python / Go / Other |
| Team / Owner | |
| Target date | |

## Service Details

### Runtime Dependencies

Select all that apply:

- [ ] PostgreSQL
- [ ] Redis
- [ ] RabbitMQ / Kafka
- [ ] External APIs (list below)

### External APIs / Services Needed for Tests

```text
<List required external APIs or services>
```

## Deployment Target

Select the deployment platform:

- [ ] AWS ECS (Fargate)
- [ ] AWS Lambda
- [ ] Static hosting (CloudFront + S3)
- [ ] Other (describe below)

| Field | Value |
|-------|-------|
| ECS service name | |
| ECS cluster(s) | |
| ECR repository name | |

## Environments Required

Select all that apply:

- [ ] Development
- [ ] Testing
- [ ] Staging
- [ ] Production

## Quality Gates

| Requirement | Value |
|-------------|-------|
| Coverage threshold | ____% (default: 80% backend, 75% frontend) |
| Security scan severity | HIGH / CRITICAL (default: HIGH) |

### Additional Quality Requirements

```text
<List additional quality requirements>
```

## Secrets / Environment Variables

List secrets that need to be added to GitHub Actions.

> **Do not include actual secret values.**

```text
SECRET_NAME_1=<description>
SECRET_NAME_2=<description>
```

## Onboarding Checklist

- [ ] Caller workflow created in `.github/workflows/backend/` or `.github/workflows/frontend/`
- [ ] ECR repository created
- [ ] ECS service and task definition created
- [ ] GitHub Environments configured (`development`, `testing`, `staging`, `production`)
- [ ] Secrets added to GitHub Actions
- [ ] Dependabot / Renovate configured
- [ ] First pipeline run verified green
- [ ] Documentation updated in `docs/onboarding.md`