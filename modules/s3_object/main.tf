resource "aws_s3_object" "html_object" {
  bucket = var.bucket_id
  key = var.object_key
  content_type = "text/html"
  content = var.html_content
  etag = md5(var.html_content)
}

