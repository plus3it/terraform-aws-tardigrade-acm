
resource "aws_acm_certificate" "this" {
  for_each = var.create_acm_certificate ? { (var.domain_name) = var.domain_name } : {}

  domain_name               = each.key
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
  for_each = var.create_acm_certificate ? local.validation_records : toset([])

  allow_overwrite = true
  name            = lookup(local.domain_validation_options, each.value, local.dummy_validation_option).resource_record_name
  type            = lookup(local.domain_validation_options, each.value, local.dummy_validation_option).resource_record_type
  ttl             = var.ttl
  zone_id         = var.zone_id

  records = [
    lookup(local.domain_validation_options, each.value, local.dummy_validation_option).resource_record_value
  ]
}

resource "aws_acm_certificate_validation" "this" {
  for_each = var.create_acm_certificate ? { (var.domain_name) = var.domain_name } : {}

  certificate_arn         = aws_acm_certificate.this[each.key].arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}

locals {
  all_records = concat([var.domain_name], var.subject_alternative_names)

  # The validation records for a zone and its wildcard ("*.<zone>") are the same.
  # To avoid a race condition creating/deleting records, construct a set that
  # does not contain both...
  validation_records = toset([
    for record in local.all_records : record if
    substr(record, 0, 2) != "*." ||
    (substr(record, 0, 2) == "*." && ! contains(local.all_records, replace(record, "*.", "")))
  ])

  # From the domain validation options for the acm certificate, create map of:
  #    domain_name => domain options
  # The domain_name will be used as the key to lookup the values for the cert
  # validtion route53 records.

  domain_validation_options = var.create_acm_certificate ? {
    for option in aws_acm_certificate.this[var.domain_name].domain_validation_options : option.domain_name => option
  } : {}

  # When the validation_records change, a resource cycle triggers correctly to
  # replace the certificate. However, local.domain_validation_options is evaluated
  # too early, leading to the error:
  #    The given key does not identify an element in this collection value.
  # It *will* exist, just *after* the certificate is recreated. In such situations,
  # this dummy map is used to provide a value for not-yet-existing domain_validation_options...
  dummy_validation_option = {
    domain_name           = ""
    resource_record_name  = ""
    resource_record_value = ""
    resource_record_type  = "CNAME"
  }
}

terraform {
  required_version = "~> 0.12.0"
}
