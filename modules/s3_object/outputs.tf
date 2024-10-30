output "object_url" {
  description = "url of the created s3 object"
  value = "http://${var.bucket_id}.s3.amazonaws.com/${aws_s3_object.html_object.key}"
}

output "etag" {
  description = "etag to detect changes in s3 object"
  value = aws_s3_object.html_object.etag
}