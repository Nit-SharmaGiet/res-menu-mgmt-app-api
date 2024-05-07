resource "aws_s3_bucket" "app_public_files" {
  bucket = "${local.prefix}-files-${data.aws_caller_identity.current.account_id}"
  #let terraform destroy it without any prompt
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "app_public_files_public_access_block" {
  bucket = aws_s3_bucket.app_public_files.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "app_public_files_policy" {
  bucket = aws_s3_bucket.app_public_files.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.app_public_files.arn}/*"
    }]
  })
}