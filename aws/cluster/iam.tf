# This service account is used by data-plane pod in the VectorMPP installation.
# e.g. create s3 bucket for warehouses.

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "data_plane" {
  name               = "${var.cluster_name}-data-plane"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.theprovider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.theprovider.url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(aws_iam_openid_connect_provider.theprovider.url, "https://", "")}:sub" = "system:serviceaccount:vectormpp-dataplane:agent"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "data_plane_policy" {
  name        = "${var.cluster_name}-data-plane-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::warehouse-av-*",
          "arn:aws:s3:::av-*",
        ]
      },
      {
        Action = [
          "iam:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AVSampleDataBucketAssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "data_plane_policy" {
  role       = aws_iam_role.data_plane.name
  policy_arn = aws_iam_policy.data_plane_policy.arn
}
