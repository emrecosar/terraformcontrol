# AWS S3 static website

This module creates requires resources to serve a static website from S3 in aws.
You can take a look at `variables.tf` and output.tf](output.tf) for inputs and outputs for steps.

## Resources to create

- s3
- route53
- cloudfront
- acm

## How to use

Order of the resource creation should be done in steps defined below.

### Step-1
- route53
- acm

### Step-2
This is an intermediate step for a manual work needs to be done by the person.
- Update domain nameserver records of the domain from the domain registrar's management console with newly created hosted zone's DNS values. You can fetch those values either terraform output or from AWS's console.
The domain can be in AWS or an external one. This operation normally happens very fast but in general the changes can be in-effect up to 48 hours. Please check the messages after updating the DNS.

### Step-3
- s3
- acm-validate
- cloudfront
- route53

### Step-4
Upload website content files into www-{DOMAIN_NAME} bucket. You can use aws cli, go into the folder that you created website content and then
```bash
  aws s3 sync . s3://www.yourdomain.com
```


#### Bonus
After the certificate validation is completed, actual certificate status is changed from `PENDING_VALIDATION` to `ISSUED`. To reflect this update to terraform state, you may need `terragrunt apply -refresh-only` at the end to avoid any drift.


## How to destroy

If you need to destory the resources, here is the order
1. Empty S3 buckets
