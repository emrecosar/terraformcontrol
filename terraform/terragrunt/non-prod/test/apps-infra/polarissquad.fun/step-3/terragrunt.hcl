locals {
  account = yamldecode(file(find_in_parent_folders("account.yaml")))

  owner   = "Emre Cosar"
  project = "polarissquad.fun"
}

include {
  path = find_in_parent_folders()
}

dependency "step_1" {
  config_path = "../step-1"
}

terraform {
  source = "../../../../..//modules/aws-s3-static-website/step-3"
}

inputs = {

  domain_name = "polarissquad.fun"
  bucket_name = "polarissquad.fun"

  aws_route53_zone_id           = dependency.step_1.outputs.route53_hosted_zone_id
  acm_domain_validation_options = dependency.step_1.outputs.acm_domain_validation_options
  acm_arn                       = dependency.step_1.outputs.acm_arn

  common_tags = {
    "Owner"   = "Emre Cosar"
    "Project" = "polarissquad.fun"
  }

}
