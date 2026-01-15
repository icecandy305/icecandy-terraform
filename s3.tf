resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "shared_customer" {
  bucket = "customer-files-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "shared_customer" {
  bucket = aws_s3_bucket.shared_customer.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "oac_policy" {
  bucket = aws_s3_bucket.shared_customer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontServicePrincipal"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.shared_customer.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.customer_cdn.arn
        }
      }
    }]
  })
}
