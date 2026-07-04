output "repository_urls" {
  description = "Repository name -> full ECR URL (used in Helm image references)"
  value       = { for name, repo in module.ecr : name => repo.repository_url }
}

output "repository_arns" {
  description = "Repository name -> ARN (consumed by the CI role's push policy)"
  value       = { for name, repo in module.ecr : name => repo.repository_arn }
}
