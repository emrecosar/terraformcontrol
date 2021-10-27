variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "common_tags" {
  type        = map(any)
  description = "Common tags you want applied to all components."
}
