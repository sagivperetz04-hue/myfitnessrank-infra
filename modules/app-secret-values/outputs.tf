output "secret_arns" {
  description = "ARNs of the per-env consolidated app secrets"
  value       = { for env, s in aws_secretsmanager_secret.app : env => s.arn }
}
