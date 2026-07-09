# One role for all backup CronJobs, bound to each chart's ServiceAccount via
# pod identity (same pattern as the EBS CSI role in modules/eks). Upload-only:
# a compromised job can add objects but never read or delete existing backups.
resource "aws_iam_role" "backup" {
  name = "${var.cluster_name}-db-backups"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy" "put_backups" {
  name = "put-backups"
  role = aws_iam_role.backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject"]
      Resource = "${var.bucket_arn}/*"
    }]
  })
}

resource "aws_eks_pod_identity_association" "backup" {
  for_each = { for a in var.associations : "${a.namespace}/${a.service_account}" => a }

  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = aws_iam_role.backup.arn
}
