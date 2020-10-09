# terraform-aws-tardigrade-acm

A Terraform module to create DNS-validated certificates using ACM

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate\_transparency\_logging\_preference | Value to apply to the certificate transparency logging preference for the ACM certificate | `string` | `"ENABLED"` | no |
| domain\_name | Domain name to use for the ACM certificate | `string` | `""` | no |
| subject\_alternative\_names | Subject alternative names to associate with the ACM certificate | `list(string)` | `[]` | no |
| tags | Map of tags to apply to all resources that support tags | `map(string)` | `{}` | no |
| ttl | Time-to-live for the DNS validation records | `number` | `300` | no |
| zone\_id | Route53 zone ID in which to create the DNS validation records | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| acm\_certificate | The ACM certificate object |
| acm\_certificate\_validation | The ACM certificate validation object |
| route53\_validation\_records | Map of Route53 validation record objects, one per unique domain name and SAN |

<!-- END TFDOCS -->
