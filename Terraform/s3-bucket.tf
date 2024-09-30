#S3 Bucket for hosting static content
resource "aws_s3_bucket" "webapp_dev_s3" {
  bucket = "webapp-dev-${random_id.random_id.hex}"
  tags = {
    Name        = "webapp-dev-s3-static"
    Environment = "Dev"
  }
}

#Bucket Ownership Control
resource "aws_s3_bucket_ownership_controls" "ownership_control" {
  bucket = aws_s3_bucket.webapp_dev_s3.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#Enable Versioning of the S3 Bucket
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.webapp_dev_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Enable Server-Side Encryption using SSE-S3 through AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_s3" {
  bucket = aws_s3_bucket.webapp_dev_s3.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#Block all public access to the Bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.webapp_dev_s3.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Define Lifecycle rules for the objects in the S3 Bucket
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_config" {
  bucket = aws_s3_bucket.webapp_dev_s3.id
  rule {
    id     = "transition-and-expiration"
    status = "Enabled"
    filter {
      prefix = "static/"
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "lb_logs_policy" {
  bucket = aws_s3_bucket.webapp_dev_s3.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowALBLogging",
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action   = "s3:*",
        Resource = "${aws_s3_bucket.webapp_dev_s3.arn}/*"
      }
    ]
  })
}