variable "role_name" {
  description = "Name of the IAM role GitHub Actions assumes"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository (owner/name) allowed to assume the role"
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the role may push to"
  type        = list(string)
}
