variable "cluster_name" {
  description = "EKS cluster to install ArgoCD into"
  type        = string
}

variable "chart_version" {
  description = "argo-cd Helm chart version"
  type        = string
}
