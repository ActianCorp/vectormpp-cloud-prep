data "aws_caller_identity" "current" {}

resource "aws_iam_role" "dummy" {
  name = "vectormpp-dummy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "AVSampleDataBucketAssumeRole" {
  # IMPORTANT: This Name must remain exactly as-is.
  name = "AVSampleDataBucketAssumeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/vectormpp-dummy-role"
      }
    }]
  })
}

resource "aws_iam_policy" "AVSampleDataReadObjectAccessPolicy" {
  name        = "AVSampleDataReadObjectAccessPolicy"
  description = "Policy to grant read access to aws-ingres-eng-eu-central-1-sampledata bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.sample_bucket_name}/*",
          "arn:aws:s3:::${var.sample_bucket_name}",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_to_role" {
  role       = aws_iam_role.AVSampleDataBucketAssumeRole.name
  policy_arn = aws_iam_policy.AVSampleDataReadObjectAccessPolicy.arn
}
