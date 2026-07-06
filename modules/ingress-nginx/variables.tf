variable "cluster_name" {
  description = "EKS cluster to install the ingress controller into"
  type        = string
}

variable "chart_version" {
  description = "ingress-nginx chart version"
  type        = string
}

variable "certificate_arn" {
  description = "ISSUED ACM certificate ARN terminated at the NLB's 443 listener"
  type        = string
}
