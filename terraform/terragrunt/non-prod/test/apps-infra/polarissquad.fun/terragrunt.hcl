locals {
  account = yamldecode(file(find_in_parent_folders("account.yaml")))

  owner   = "Emre Cosar"
  project = "polarissquad.fun"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//modules/aws-s3-static-website"
}

inputs = {

  domain_name = "polarissquad.fun"
  bucket_name = "polarissquad.fun"

  common_tags = {
    "Owner"   = "Emre Cosar"
    "Project" = "polarissquad.fun"
  }

}
