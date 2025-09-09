resource "aws_security_group" "efs_sg" {
  name        = "${var.cluster_name}-efs-sg"
  description = "Allow EKS nodes to access EFS"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  security_group_id = aws_security_group.efs_sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 2049
  to_port           = 2049
}

resource "aws_efs_file_system" "efs" {
  tags = {
    Name = "${var.cluster_name}-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  depends_on = [
    aws_eks_node_group.first,
  ]
  count           = 3
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private_subnet.*.id[count.index]
  security_groups = ["${aws_security_group.efs_sg.id}"]
}

# IMPORTANT: DO NOT MODIFY the following values.
# These settings are required for VectorMPP to interact correctly with the EFS volumes.
# - uid: must be "1000" for container user permission compatibility
# - gid: must be "3000" to match the expected group ownership
# - mount_options = ["noac"]: disables attribute caching to ensure consistency across pods
# Changing these values may result in permission errors, file access issues, or data inconsistency.
resource "kubernetes_storage_class" "efs_sc" {
  metadata {
    name = "efs-sc"
  }
  parameters = {
    fileSystemId = aws_efs_file_system.efs.id
    provisioningMode = "efs-ap"
    directoryPerms = "777"
    uid = "1000"
    gid = "3000"
    basePath = "/dynamic_provisioning"
  }
  mount_options = [
    "noac"
  ]
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}
