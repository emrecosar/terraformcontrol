# SSL Certificate & Validation
locals {
  acm_default_region = "us-east-1"
}
provider "aws" {
  alias  = "acm_provider"
  region = local.acm_default_region
}

resource "aws_route53_record" "main" {
  for_each = {
    for dvo in var.acm_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.aws_route53_zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = var.acm_arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}
