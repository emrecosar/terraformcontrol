variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "common_tags" {
  type        = map(any)
  description = "Common tags you want applied to all components."
}

variable "aws_route53_zone_id" {
  type        = string
  description = "aws route53 zone id"
}

variable "acm_domain_validation_options" {
  type        = map(any)
  description = "ACM domain validation options"
}

variable "acm_arn" {
  type        = string
  description = "ACM arn"
}
