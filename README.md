# terraform-aws-tardigrade-acm

A Terraform module to create DNS-validated certificates using ACM

## Testing

At the moment, testing is manual and requires access to the Plus3IT account
303523384066 where the zone tardigrade.cloudarmor.io exists:

```
# Replace "xxx" with the AWS profile, then execute the integration tests.
AWS_PROFILE=xxx make terraform/pytest PYTEST_ARGS="-v --nomock"
```

<!-- BEGIN TFDOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name to use for the ACM certificate | `string` | n/a | yes |
| <a name="input_certificate_transparency_logging_preference"></a> [certificate\_transparency\_logging\_preference](#input\_certificate\_transparency\_logging\_preference) | Value to apply to the certificate transparency logging preference for the ACM certificate | `string` | `"ENABLED"` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | Subject alternative names to associate with the ACM certificate | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to all resources that support tags | `map(string)` | `{}` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Time-to-live for the DNS validation records | `number` | `300` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 zone ID in which to create the DNS validation records | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate"></a> [acm\_certificate](#output\_acm\_certificate) | The ACM certificate object |
| <a name="output_acm_certificate_validation"></a> [acm\_certificate\_validation](#output\_acm\_certificate\_validation) | The ACM certificate validation object |
| <a name="output_route53_validation_records"></a> [route53\_validation\_records](#output\_route53\_validation\_records) | Map of Route53 validation record objects, one per unique domain name and SAN |

<!-- END TFDOCS -->
