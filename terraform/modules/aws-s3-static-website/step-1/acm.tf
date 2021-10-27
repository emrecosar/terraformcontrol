# SSL Certificate & Validation
locals {
  acm_default_region = "us-east-1"
}

provider "aws" {
  alias  = "acm_provider"
  region = local.acm_default_region
}

resource "aws_acm_certificate" "ssl_certificate" {
  provider                  = aws.acm_provider
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = var.common_tags
  lifecycle {
    create_before_destroy = true
  }
}
