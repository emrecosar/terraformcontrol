output "s3_root_arn" {
  value       = aws_s3_bucket.root_bucket.arn
  description = "S3 root arn"
}

output "s3_www_arn" {
  value       = aws_s3_bucket.www_bucket.arn
  description = "S3 www arn"
}

output "cloudfront_s3_root_arn" {
  value       = aws_cloudfront_distribution.root_s3_distribution.arn
  description = "cloudfront s3 distribution arn"
}

output "cloudfront_s3_www_arn" {
  value       = aws_cloudfront_distribution.www_s3_distribution.arn
  description = "cloudfront s3 distribution arn"
}

output "acm_validation_id" {
  value       = aws_acm_certificate_validation.cert_validation.id
  description = "acm validation id"
}
