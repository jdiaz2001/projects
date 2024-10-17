data "aws_region" "current" {}

# New Bucket
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = "s3-project-javiercloud"

  tags = {
    Name        = "Static Website Bucket"
    Environment = "Production"
  }
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Enable public access block for the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.static_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Define the S3 bucket policy to allow public access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_website_bucket.arn}/*"
      }
    ]
  })
}

# Versioning disabled
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.static_website_bucket.id
  versioning_configuration {
    status = "Suspended"  # Equivalent to enabled = false
  }
}
# Upload index.html and error.html files to the bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_website_bucket.bucket
  key    = "index.html"
  source = "/Users/javier/Work/Training/terraform/projects/s3-project/website/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static_website_bucket.bucket
  key    = "error.html"
  source = "/Users/javier/Work/Training/terraform/projects/s3-project/website/error.html"
  content_type = "text/html"
}

# Output the website URL
output "website_url" {
  value       = "http://${aws_s3_bucket.static_website_bucket.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
  description = "The URL of the static website"
}


