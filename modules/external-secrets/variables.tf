variable "cluster_name" {
  description = "EKS cluster to install External Secrets Operator into"
  type        = string
}

variable "chart_version" {
  description = "external-secrets helm chart version"
  type        = string
}

variable "project" {
  description = "Secrets Manager name prefix the operator may read"
  type        = string
}
