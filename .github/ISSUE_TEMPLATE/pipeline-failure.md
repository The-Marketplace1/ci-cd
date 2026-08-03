---
name: Pipeline Failure
about: Report a CI/CD pipeline failure
title: "🔴 Pipeline failure: [service] on [branch]"
labels: "[pipeline-failure, needs-triage]"
assignees: []
---

# Pipeline Failure Report

## Pipeline Details

| Field | Value |
|-------|-------|
| Service / App | |
| Branch | |
| Workflow | |
| Run URL | |
| Failed Job | |
| Failure Time | |

## Failure Summary

```text
<error output>
```

## Steps to Reproduce

- What was pushed or triggered this run?
- Was this a first-time failure or a regression?
- Were there any recent changes to the service or this repository?

## Impact

Select all that apply:

- [ ] Blocks deployment to development
- [ ] Blocks deployment to staging
- [ ] Blocks deployment to production
- [ ] Flaky — intermittent failure

## Attempted Fixes

Describe any troubleshooting steps or fixes already attempted:

## Resolution Checklist

- [ ] Root cause identified
- [ ] Fix applied
- [ ] Pipeline verified green
- [ ] Post-mortem written (if production was impacted)