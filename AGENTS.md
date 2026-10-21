# Agent Instructions for Plus3 IT Repositories

<!-- BEGIN plus3it-shared: shared across Plus3 IT repositories; change it in plus3it/repo-template, then copy it to the others -->
## Overview

Plus3 IT repositories use tardigrade-ci for linting, testing, and releases. Run `make help` to list every target, and prefer make targets over running tools directly. Repository-specific instructions follow this shared section.

## Before you finish

1. Run `make lint`.
2. Run the tests described in Repository-specific → Testing.
3. For user-visible changes in a repository with `.bumpversion.cfg`: add a `CHANGELOG.md` entry ([Keep a Changelog](http://keepachangelog.com/) format) and commit it with your changes, then run `make bumpversion/patch` (or `minor` or `major`), which creates its own commit. Both commits go in the same pull request.
4. Regenerate any generated docs, for example `make docs/generate` for Terraform module READMEs.
5. In your final report, list everything a person must still do (pushes, pull requests, applies, account or credential setup) and anything you could not verify.

## Tooling

- `make lint`, `make test`, and `make <lang>/format` (for example, `make terraform/format`).
- `make docker/run target=<target>` runs a target inside the pinned tardigrade-ci container.
- The `Dockerfile` line `FROM plus3it/tardigrade-ci:<version>` pins tardigrade-ci, and the Makefile bootstrap clones the same version.

## Releases

On GitHub, merging a version bump to the default branch runs `.github/workflows/release.yml`, which creates a release and tag for the new version; GitHub generates the release notes. On other hosts, see Repository-specific → CI/CD.

## Dependency automation

- **GitHub**: Dependabot (`.github/dependabot.yml`) opens update pull requests, and Mergify (`.mergify.yml`) auto-approves and merges them.
- **Other hosts (for example, GitLab)**: Renovate (`renovate.json`), run from the host's CI.

## Formatting

Follow `.editorconfig`; check with `make ec/lint`.
<!-- END plus3it-shared -->

## Repository-specific

### Purpose

This Terraform module manages DNS-validated ACM (AWS Certificate Manager) certificates. It creates an ACM certificate for a domain name with optional subject alternative names (SANs), creates the required Route53 DNS validation records in the specified hosted zone, and optionally creates the certificate validation resource to wait for AWS to validate the certificate.

### Layout

Root module files:
- `main.tf` — ACM certificate, Route53 validation records, and certificate validation resources
- `variables.tf` — Input variables for domain name, zone ID, SANs, tags, and validation options
- `outputs.tf` — Outputs for the certificate, validation, and Route53 record objects
- `migrations.tf` — Contains `moved` blocks to allow users to upgrade the module without destroying and recreating resources

Test scenarios in `tests/<scenario>/`:
- Each test scenario directory contains `main.tf` that uses the module
- If a test requires prerequisite resources (e.g., a Route53 zone), those Terraform files go in a `prereq/` subdirectory within the test scenario

### Interface changes

When adding or changing a variable or output:
1. Update the README documentation by running `make docs/generate`. This regenerates the content between `<!-- BEGIN TFDOCS -->` and `<!-- END TFDOCS -->` markers. Do not edit the generated tables manually.
2. If the change renames or moves a resource address (for example, adding `count` or `for_each`), add a `moved` block to `migrations.tf` (create it if absent) so existing users do not destroy and recreate resources.
3. For new or changed inputs, add a test scenario under `tests/` that exercises them.
4. Add an entry to `CHANGELOG.md` following [Keep a Changelog](http://keepachangelog.com/) format.
5. Commit your changes, including the CHANGELOG.md entry.
6. Run the appropriate semantic version bump, which creates its own commit:
    - `make bumpversion/patch` — Bug fixes (1.2.3 → 1.2.4)
    - `make bumpversion/minor` — New features, backward-compatible (1.2.3 → 1.3.0)
    - `make bumpversion/major` — Breaking changes, including variable removals or type changes (1.2.3 → 2.0.0)
7. Both commits go in the same pull request.

### Testing

Tests run in Docker using mockstack. CI uses the plus3it/actions-workflows `test.yml` workflow, which runs:

```bash
make mockstack/up       # Start the mock AWS stack
make mockstack/pytest   # Run tests
make mockstack/clean    # Clean up
```

Run exactly these three commands (Docker is required). Do not substitute `make test` or `make docker/run target=test`: they do not start the mock AWS services, and host `make test` uses host Python packages, which can differ from the versions tardigrade-ci pins in its `tests/terraform_pytest/requirements.txt`. If Docker is unavailable, say so in your final report.

Tests use moto by default. Set `USE_LOCALSTACK` (for example, `USE_LOCALSTACK := true` in the Makefile) only if a test needs LocalStack. `ONLY_MOTO` is obsolete and has no effect; if a Makefile still sets it, it can be removed.

Each test scenario in `tests/` must contain:
- `main.tf` — Terraform configuration that uses the module
- `prereq/` subdirectory (optional) — Terraform files to create prerequisite resources before the test runs

New features should include a corresponding test scenario.

### CI/CD

Pull requests trigger two workflows:
- `lint.yml` — Runs linters and static analysis checks
- `test.yml` — Runs test scenarios

Releases are created automatically when a PR updating `.bumpversion.cfg` is pushed to the master branch. The `release.yml` workflow creates a GitHub Release and tag. All workflows use reusable workflows from plus3it/actions-workflows.
