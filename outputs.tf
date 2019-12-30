output "acm_certificate" {
  description = "The ACM certificate object"
  value       = aws_acm_certificate.this
}

output "acm_certificate_validation" {
  description = "The ACM certificate validation object"
  value       = aws_acm_certificate_validation.this
}

output "route53_validation_records" {
  description = "Map of Route53 validation record objects, one per unique domain name and SAN"
  value       = aws_route53_record.this
}
