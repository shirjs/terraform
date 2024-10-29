output "website_url" {
  description = "url of the s3 static website"
  value = "http://${aws_s3_bucket.website_bucket.bucket_regional_domain_name}/index.html"
}

output "bucket_name" {
  description = "name of the created s3 bucket"
  value = aws_s3_bucket.website_bucket.id
}

output "bucket_arn" {
  description = "ard of the created s3 bucket"
  value = aws_s3_bucket.website_bucket.arn
}