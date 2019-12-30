locals {
  test_id = length(data.terraform_remote_state.prereq.outputs) > 0 ? data.terraform_remote_state.prereq.outputs.random_string.result : ""

  zone_name   = "cloudarmor.io"
  domain_name = "tardigrade-${local.test_id}.test.${local.zone_name}"
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

module "create_certificate" {
  source = "../../"

  zone_id     = data.aws_route53_zone.this.zone_id
  domain_name = "${local.domain_name}"

  subject_alternative_names = [
    "*.${local.domain_name}"
  ]
}

output "create_certificate" {
  value = module.create_certificate
}
