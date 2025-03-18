variable "certificate_transparency_logging_preference" {
  description = "Value to apply to the certificate transparency logging preference for the ACM certificate"
  type        = string
  default     = "ENABLED"
}

variable "create_certificate_validation" {
  description = "Boolean controlling whether to create the ACM certificate validation resource"
  type        = bool
  nullable    = false
  default     = true
}

variable "domain_name" {
  description = "Domain name to use for the ACM certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names to associate with the ACM certificate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Map of tags to apply to all resources that support tags"
  type        = map(string)
  default     = {}
}

variable "ttl" {
  description = "Time-to-live for the DNS validation records"
  type        = number
  default     = 300
}

variable "zone_id" {
  description = "Route53 zone ID in which to create the DNS validation records"
  type        = string
}

variable "zone_name" {
  description = "Route53 zone name of zone_id, used to determine whether to create a validation record in the provided zone"
  type        = string
  default     = null
}
