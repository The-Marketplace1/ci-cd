# Release Process

## Versioning

Releases follow **Semantic Versioning (SemVer)** and use **Conventional Commits** to determine the next version.

| Commit format | Version change |
|--------------|----------------|
| `fix: ...` | Patch |
| `feat: ...` | Minor |
| `feat!: ...` or `BREAKING CHANGE:` | Major |

Each service maintains an independent release history using tags in the following format:

```text
<service>@<version>
```

Example:

```text
auth-service@2.3.0
```

## Creating a release

To create a release:

1. Open **GitHub Actions** → **Create Release**.
2. Select the service or application.
3. Choose one of the following release types:
   - `auto`
   - `patch`
   - `minor`
   - `major`
4. For high-risk releases, run a **dry run** first.
5. Execute the release workflow without `dry-run` to publish the release.

The reusable release workflow automatically:

- Reads previous service tags.
- Calculates the next semantic version.
- Generates a changelog from Conventional Commits.
- Creates an annotated Git tag.
- Publishes a GitHub Release.
- Triggers the production deployment workflow.

## Changelog generation

The changelog generator groups commits into the following categories:

- Breaking Changes
- Features
- Bug Fixes
- Performance Improvements
- Dependency Updates

> Write clear Conventional Commit messages. Ambiguous commit subjects produce less useful release notes.

## Preconditions

Before creating a release, ensure that:

- The `main` branch is green and protected.
- The release has successfully passed **Staging** validation.
- Required GitHub Environment approvals are configured.
- A designated service owner is available to monitor the production deployment.