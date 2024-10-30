variable "bucket_id" {
  description = "ID of the bucket being used to store the object"
  type = string
}

variable "object_key" {
  description = "path for the s3 object"
  type = string
}

variable "html_content" {
  description = "html content of the object"
  type = string
}

