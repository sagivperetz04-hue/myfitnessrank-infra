output "role_arn" {
  description = "IAM role ARN for the AWS_ROLE_ARN GitHub Actions secret"
  value       = aws_iam_role.ci.arn
}
