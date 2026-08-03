# Rollback Process

## Automatic rollback

The deployment workflow automatically initiates a rollback when any of the following occurs:

- Deployment failure
- Health check failure
- Smoke test failure

During an automatic rollback, the workflow:

1. Reverts the service to the previous Amazon ECS task definition revision.
2. Waits for Amazon ECS to report service stability.
3. Verifies the application's health.
4. Sends a Slack notification with the rollback status.

> **Important:** Automatic rollback restores application availability but **does not** revert database changes. Database migrations must remain backward compatible until the associated application version has been safely retired.

## Manual rollback

Use the service's manual deployment or rollback workflow, or execute the rollback helper using an authorized AWS identity.

```bash
bash scripts/rollback-service.sh \
  --service orders-service \
  --cluster production-cluster \
  --target-revision 42
```

To roll back to the task definition immediately preceding the active revision, omit the `--target-revision` option.

## Incident checklist

When performing a production rollback:

1. Declare the incident using the organization's incident management process.
2. Stop or pause additional deployments to the affected environment.
3. Roll back the affected service.
4. Verify:
   - Application health
   - Error rates
   - Critical user journeys
5. Communicate the outcome and customer impact.
6. Preserve logs, deployment records, and workflow links for investigation.
7. Create follow-up remediation work before closing the incident.

## Rollback limitations

Do **not** perform an automatic or manual rollback without review if the deployment includes:

- An irreversible database migration
- A data backfill
- An external side effect that cannot be safely reversed

In these situations:

- Engage the database owner and incident commander before proceeding.
- If the previous ECS task definition is unavailable, deploy a known-good immutable image revision using the manual deployment workflow.