terraform {
  required_version = ">= 0.13.0"
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = var.tags

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "this" {
  for_each = {
    for record in local.validation_records : record => local.domain_validation_options[record]
    if endswith(record, data.aws_route53_zone.this.name)
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  ttl             = var.ttl
  zone_id         = var.zone_id

  records = [
    each.value.resource_record_value,
  ]
}

resource "aws_acm_certificate_validation" "this" {
  count = var.create_certificate_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}

locals {
  # The validation records for a zone and its wildcard ("*.<zone>") are the same.
  # To avoid a race condition creating/deleting records, construct a set that
  # does not contain both...
  validation_records = toset([
    for record in concat([var.domain_name], var.subject_alternative_names) : trimprefix(record, "*.")
  ])

  # From the domain validation options for the acm certificate, create map of:
  #    domain_name => domain options
  # The domain_name is used as the key to lookup the values for the cert
  # validation route53 records.
  domain_validation_options = {
    for option in aws_acm_certificate.this.domain_validation_options : option.domain_name => option
  }
}

data "aws_route53_zone" "this" {
  zone_id = var.zone_id
}
