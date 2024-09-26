module "create_certificate" {
  source = "../../"

  zone_id     = data.aws_route53_zone.this.zone_id
  domain_name = local.domain_name

  # Disable certificate validation due to the SAN "biz.cloudarmor.io", where the
  # zone is not the same as the zone of the zone_id, "tardigrade.cloudarmor.io"
  create_certificate_validation = false

  subject_alternative_names = [
    "*.${local.domain_name}",
    "foo.${local.domain_name}",
    "bar.${local.domain_name}",
    "baz.${local.domain_name}",
    "biz.cloudarmor.io",
  ]
}

locals {
  test_id = data.terraform_remote_state.prereq.outputs.random_string.result

  domain_name = "${local.test_id}.test.${local.zone_name}"
  zone_name   = "tardigrade.cloudarmor.io"
}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

data "aws_route53_zone" "this" {
  name         = local.zone_name
  private_zone = false
}

output "create_certificate" {
  value     = module.create_certificate
  sensitive = true
}
