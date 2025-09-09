resource "aws_iam_user" "cluster_creator" {
  name = "vectormpp-cluster-creator"
}

resource "aws_iam_policy" "ec2_vpc_policy" {
  name        = "ec2_vpc_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ec2_vpc_policy" {
  user       = aws_iam_user.cluster_creator.name
  policy_arn = aws_iam_policy.ec2_vpc_policy.arn
}

resource "aws_iam_policy" "s3_policy" {
  name        = "vectormpp-cluster-creator-s3-policy"
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
        ]
      },
      {
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "s3_policy" {
  user       = aws_iam_user.cluster_creator.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_policy" "eks_policy" {
  name        = "vectormpp-cluster-creator-eks-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "eks:DescribeAddon",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "eks_policy" {
  user       = aws_iam_user.cluster_creator.name
  policy_arn = aws_iam_policy.eks_policy.arn
}

resource "aws_iam_policy" "iam_policy" {
  name        = "vectormpp-cluster-creator-iam-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:*Role",
          "iam:List*",
          "iam:Attach*",
          "iam:Detach*",
          "iam:*Policy*",
          "iam:CreateOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:GetRole",
          "iam:*OpenIDConnectProvider",
          "iam:CreateUser",
          "iam:CreateAccessKey",
          "iam:DeleteUser",
          "iam:DeleteAccessKey",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action    = "iam:UpdateAssumeRolePolicy",
        Effect    = "Allow",
        Resource  = "arn:aws:iam::*:role/AVSampleDataBucketAssumeRole"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "iam_policy_attachment" {
  user       = aws_iam_user.cluster_creator.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_policy" "efs_policy" {
  name        = "vectormpp-cluster-creator-efs-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:*",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "efs_policy" {
  user       = aws_iam_user.cluster_creator.name
  policy_arn = aws_iam_policy.efs_policy.arn
}

resource "aws_iam_policy" "autoscaling_describe_policy" {
  name        = "vectormpp-cluster-creator-asd-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "autoscaling:DescribeAutoScalingGroups"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "as_policy" {
  user       = aws_iam_user.cluster_creator.name
  policy_arn = aws_iam_policy.autoscaling_describe_policy.arn
}
