variable "cluster_name" {
  description = "EKS cluster to create the namespaces and secrets in"
  type        = string
}

variable "environments" {
  description = "Environment names run on this cluster (namespace = myfitnessrank-<env>)"
  type        = list(string)
  default     = ["staging", "prod"]
}
