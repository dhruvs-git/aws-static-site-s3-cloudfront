# S3 Bucket
resource "aws_s3_bucket" "s3_website" {
  bucket = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "website bucket"
    Environment = "production"
  }
}

# Uploading file to s3 
resource "aws_s3_object" "s3_file" {
  bucket = aws_s3_bucket.s3_website.id
  key    = "index.html"
  source = "./website/index.html"
  content_type = "text/html"
}

# Block all public access (cloudfront will access it privately)
resource "aws_s3_bucket_public_access_block" "s3_website" {
  bucket = aws_s3_bucket.s3_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "s3_website" {
  bucket = aws_s3_bucket.s3_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
    # wrong page will redirect to index.html (we can also have error page)
  }
}



# OAC - allows cloudfront to access private s3 bucket
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "default-oac"
  description                       = "OAC for the s3 website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# Cloudfront Distribution
resource "aws_cloudfront_distribution" "s3_website" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.s3_website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "s3origin"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "Static Site Distribution"
    Environment = "Production"

  }
}


# S3 bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3_website.id
  policy = templatefile("s3_bucket_policy.json.tpl", {
    bucket_arn = aws_s3_bucket.s3_website.arn
    cloudfront_arn = aws_cloudfront_distribution.s3_website.arn
  })
}
 