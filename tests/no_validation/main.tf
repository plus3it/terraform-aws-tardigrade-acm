module "create_certificate" {
  source = "../../"

  domain_name = local.domain_name

  zone_id   = aws_route53_zone.test.zone_id
  zone_name = local.zone_name

  # Disable certificate validation due to the SAN "biz.cloudarmor.io", where the
  # zone is not the same as the zone of the zone_id, "tardigrade.cloudarmor.io"
  create_certificate_validation = false

  subject_alternative_names = [
    "*.${local.domain_name}",
    "foo.${local.domain_name}",
    "bar.${local.domain_name}",
    "baz.${local.domain_name}",
    "abc.${local.zone_name}",
    "biz.cloudarmor.io",
  ]
}

resource "aws_route53_zone" "test" {
  name = local.zone_name
}

locals {
  test_id = data.terraform_remote_state.prereq.outputs.random_string.result

  domain_name = "test.${local.zone_name}"
  zone_name   = "${local.test_id}.tardigrade.cloudarmor.io"
}

data "terraform_remote_state" "prereq" {
  backend = "local"
  config = {
    path = "prereq/terraform.tfstate"
  }
}

output "create_certificate" {
  value     = module.create_certificate
  sensitive = true
}
