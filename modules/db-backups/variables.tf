variable "cluster_name" {
  description = "EKS cluster the pod identity associations attach to"
  type        = string
}

variable "bucket_arn" {
  description = "Backup bucket ARN the role may PutObject into"
  type        = string
}

variable "associations" {
  description = "ServiceAccounts (namespace + name) that upload backups"
  type = list(object({
    namespace       = string
    service_account = string
  }))
}
