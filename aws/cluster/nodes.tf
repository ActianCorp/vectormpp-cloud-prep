resource "aws_iam_role" "node" {
  name               = "${var.cluster_name}-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

data "aws_ssm_parameter" "eks_optimized_ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_cluster.version}/amazon-linux-2/recommended/release_version"
}

resource "aws_eks_node_group" "first" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-first"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.private_subnet[*].id
  release_version = nonsensitive(data.aws_ssm_parameter.eks_optimized_ami.value)
  disk_size       = 100
  instance_types  = ["${var.node_type}"]
  scaling_config {
    desired_size = var.min_node_count
    min_size     = var.min_node_count
    max_size     = var.max_node_count
  }
  update_config {
    max_unavailable = 1
  }
  lifecycle {
    ignore_changes = [scaling_config.0.desired_size]
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_addon.cni,
    aws_eks_addon.kube_proxy,
  ]
  tags = {
    BelongTo = "VectorMPP"
  }
}
