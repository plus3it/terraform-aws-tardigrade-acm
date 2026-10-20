# Agent Instructions for Plus3 IT Repositories

This file provides instructions for AI agents working with Plus3 IT repositories. Every repository created from this template inherits these instructions.

## Overview

Plus3 IT repositories follow a standardized structure using tardigrade-ci tooling for development, testing, and releases. Most repositories are hosted on GitHub and use reusable workflows from plus3it/actions-workflows.

## Before you finish

Before reporting your work as complete:

1. Run `make lint` to catch formatting and style issues
2. Run tests as described in the Repository-specific → Testing section
3. For user-visible changes in repos with `.bumpversion.cfg`:
    - Update `CHANGELOG.md` following [Keep a Changelog](http://keepachangelog.com/) format
    - Commit your changes, including the CHANGELOG.md entry
    - Run the appropriate version bump (`make bumpversion/patch`, `minor`, or `major`), which creates its own commit
    - Both commits go in the same pull request
4. Regenerate any maintained documentation (e.g., `make docs/generate` for Terraform module READMEs)
5. In your final report, list everything a person must still do: pushes, pull requests, applies, account or credential setup, and anything you could not verify

## Tooling

Repositories created from this template include tardigrade-ci, a Docker-based test framework that provides standardized make targets for development tasks.

### Available Commands

Run `make help` to see all available targets. Common targets include:

- `make lint` — Runs all linters (editorconfig, YAML, JSON, shell scripts, Python, Terraform, HCL)
- `make test` — Runs tests (typically Terraform pytest via mockstack)
- `make docker/run target=<TARGET>` — Runs a make target inside the tardigrade-ci Docker container
- `make <lang>/format` — Formats files (e.g., `make python/format`, `make terraform/format`, `make hcl/format`, `make json/format`)

### Docker Image and Makefile

The `Dockerfile` at the repository root pins the tardigrade-ci version with a `FROM plus3it/tardigrade-ci:<version>` line. The repository's dependency bot (Dependabot or Renovate; see Repository Automation) updates this pin. The Makefile bootstrap reads the same pin to clone the matching tardigrade-ci version.

The repository Makefile includes tardigrade-ci's bootstrap:

```makefile
include $(shell test -f .tardigrade-ci || curl -sSL -o .tardigrade-ci "https://raw.githubusercontent.com/plus3it/tardigrade-ci/master/bootstrap/Makefile.bootstrap"; echo .tardigrade-ci)
```

This bootstrap automatically clones or updates the tardigrade-ci tooling into a local subdirectory based on the Dockerfile pin.

## Release Process

Use bump2version to increment the version in `.bumpversion.cfg`:

```bash
make bumpversion/patch   # For bug fixes (1.2.3 → 1.2.4)
make bumpversion/minor   # For new features (1.2.3 → 1.3.0)
make bumpversion/major   # For breaking changes (1.2.3 → 2.0.0)
```

This command updates `current_version` in `.bumpversion.cfg` and commits the change (the config has `commit = True` and `tag = False`). Update `CHANGELOG.md` in the same PR following [Keep a Changelog](http://keepachangelog.com/) format.

On GitHub, when the PR merging the version bump is pushed to the default branch (main or master), the release workflow (`.github/workflows/release.yml`) runs automatically. The workflow creates a GitHub Release and tag named after `current_version` ONLY if that version differs from the latest existing tag. Release notes are generated automatically by GitHub, not extracted from CHANGELOG.md. On other hosts, see Repository-specific → CI/CD for the release process.

## Repository Automation

Dependency updates depend on where the repository is hosted:

- **GitHub**: Dependabot (`.github/dependabot.yml`) opens update PRs, and Mergify (`.mergify.yml`) auto-approves and merges Dependabot PRs. Mergify has no rules for other PRs.
- **Other hosts (for example, GitLab)**: Renovate (`renovate.json`) opens update merge requests, run by the host's CI. Dependabot and Mergify do not work there.

Check which of these files the repository has before changing dependency automation.

## Formatting

All repositories follow `.editorconfig` rules. Validate formatting with `make ec/lint`.

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
