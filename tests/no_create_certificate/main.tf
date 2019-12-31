module "create_certificate" {
  source = "../../"

  create_acm_certificate = false
}

output "create_certificate" {
  value = module.create_certificate
}
