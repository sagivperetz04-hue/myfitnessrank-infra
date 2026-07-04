variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane"
  type        = string
}

variable "vpc_id" {
  description = "VPC the cluster lives in"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the control plane ENIs and worker nodes"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
}

variable "node_min" {
  description = "Minimum node count"
  type        = number
}

variable "node_max" {
  description = "Maximum node count"
  type        = number
}

variable "node_desired" {
  description = "Desired node count"
  type        = number
}
