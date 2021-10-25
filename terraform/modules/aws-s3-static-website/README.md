# AWS S3 static website

This module creates some resources to serve a static website from S3 in aws.
You can take a look at [variables.tf](variables.tf) and [output.tf](output.tf) for inputs and outputs.

### resources

- s3
- route53
- cloudfront
- acm

#### Issues

- `domain_name` should point to the created route53 hosted zone name servers to validate the certificate. To do that, you need to run the module once and let the route53 is created. Then update your domain's name servers with newly created route53's name servers, wait for a while to be reflected and then apply one more time.
- After the certificate validation is completed, actual certificate status is changed from `PENDING_VALIDATION` to `ISSUED`. To reflect this update to terraform state, you need `terragrunt apply -refresh-only` at the end.
