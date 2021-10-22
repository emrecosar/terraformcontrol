provider "aws" {
  region = "${aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${aws_account_id}"]

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}
