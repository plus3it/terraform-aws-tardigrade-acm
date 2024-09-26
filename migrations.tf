moved {
  from = aws_acm_certificate_validation.this
  to   = aws_acm_certificate_validation.this[0]
}
