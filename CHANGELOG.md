## terraform-aws-tardigrade-acm Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

### [1.2.0](https://github.com/plus3it/terraform-aws-tardigrade-ec2-account/releases/tag/1.2.0)

**Released**: 2025.03.17

**Summary**:

*   Accepts `zone_name` input to avoid data lookup that breaks zone creation and
    acm validation in the same, single terraform configuration

### [1.1.0](https://github.com/plus3it/terraform-aws-tardigrade-ec2-account/releases/tag/1.1.0)

**Released**: 2024.09.25

**Summary**:

*   Adds the input `create_certificate_validition` to control whether the ACM certificate
    will be validated at creation time
*   Avoids creating DNS records where the zone is not the same as the zone of the
    `zone_id` input

### 1.0.2

**Commit Delta**: [Change from 1.0.1 release](https://github.com/plus3it/terraform-aws-tardigrade-acm/compare/1.0.1...1.0.2)

**Released**: 2022.12.19

**Summary**:

*   No functional changes
*   Updates release action to fix usage of reusable workflow

### 1.0.1

**Commit Delta**: [Change from 1.0.0 release](https://github.com/plus3it/terraform-aws-tardigrade-acm/compare/1.0.0...1.0.1)

**Released**: 2022.12.05

**Summary**:

*   No functional changes
*   Begins switch from Travis-CI to GitHub Actions

### 0.0.0

**Commit Delta**: N/A

**Released**: 2019.12.30

**Summary**:

*   Initial release!
