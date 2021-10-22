locals {
  account     = yamldecode(file(find_in_parent_folders("account.yaml")))
  bucket_name = format("%s-terraform-state", local.account.s3_resource_name_prefix)
}

resource "aws_s3_bucket" "terraform_state_aws_bucket" {
  bucket_name = local.bucket_name
  
  policy = templatefile("s3-policy.json", { bucket_name = local.bucket_name })

  tags = var.common_tags
}