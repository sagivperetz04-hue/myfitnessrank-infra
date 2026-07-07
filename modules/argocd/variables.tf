variable "cluster_name" {
  description = "EKS cluster to install ArgoCD into"
  type        = string
}

variable "chart_version" {
  description = "argo-cd chart version"
  type        = string
}

variable "apps_chart_version" {
  description = "argocd-apps chart version (plants the root Application)"
  type        = string
}

variable "gitops_repo_url" {
  description = "Git repo ArgoCD pulls all workloads from (the app repo)"
  type        = string
}

variable "gitops_revision" {
  description = "Branch the root Application tracks"
  type        = string
  default     = "master"
}

variable "gitops_path" {
  description = "Path within the repo holding this cluster's app-of-apps"
  type        = string
  default     = "deploy/argocd/aws"
}
