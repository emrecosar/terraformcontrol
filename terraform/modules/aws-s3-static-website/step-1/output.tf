output "route53_hosted_zone_name_servers" {
  value       = aws_route53_zone.main.name_servers
  description = "route53 hosted zone name servers"
}

output "route53_hosted_zone_id" {
  value       = aws_route53_zone.main.zone_id
  description = "route53 hosted zone id"
}

output "acm_id" {
  value       = aws_acm_certificate.ssl_certificate.id
  description = "acm certificate id"
}

output "acm_arn" {
  value       = aws_acm_certificate.ssl_certificate.arn
  description = "acm certificate arn"
}

output "acm_domain_name" {
  value       = aws_acm_certificate.ssl_certificate.domain_name
  description = "acm certificate domain name"
}

output "acm_domain_validation_options" {
  value       = aws_acm_certificate.ssl_certificate.domain_validation_options
  description = "acm certificate domain validation options"
}

output "acm_status" {
  value       = aws_acm_certificate.ssl_certificate.status
  description = "acm certificate status"
}
