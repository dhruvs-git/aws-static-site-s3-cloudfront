variable "aws_region" {
  description = "The region in which resource will be deployed"
  type        = string
}

variable "s3_bucket_name" {
  description = "The s3 bucket in which we will host the website"
  type        = string
}