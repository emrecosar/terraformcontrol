
locals {
  account = try(yamldecode(file("non-prod/account.yaml")), null)

  tfstate_s3_bucket = format("%s-terraform-state", local.account.aws_account_id)
  tfstate_path      = format("%s/terraform.tfstate", path_relative_to_include())
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = templatefile("providers.tpl", {
    # AWS Provider
    aws_region     = local.account.aws_region
    aws_account_id = local.account.aws_account_id
  })
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt                        = true
    bucket                         = local.tfstate_s3_bucket
    key                            = local.tfstate_path
    region                         = local.account.aws_region
    enable_lock_table_ssencryption = true
    skip_bucket_enforced_tls       = false
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
