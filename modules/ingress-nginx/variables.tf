variable "cluster_name" {
  description = "EKS cluster to install ingress-nginx into"
  type        = string
}

variable "chart_version" {
  description = "ingress-nginx Helm chart version"
  type        = string
}
