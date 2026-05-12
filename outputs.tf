output "cloudfront_url" {
  description = "The URL for the website"
  value = "https://${aws_cloudfront_distribution.s3_website.domain_name}"
}

output "s3_bucket_name" {
  description = "The name of the s3 bucket"
  value = aws_s3_bucket.s3_website.id
}

output "cloudfront_destribution_id" {
  description = "The ID of the cloudfront destribution"
  value = aws_cloudfront_distribution.s3_website.id
}