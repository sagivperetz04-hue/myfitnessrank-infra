output "cluster_name" {
  description = "EKS cluster name (used by kubectl config and later units)"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "node_security_group_id" {
  description = "Security group attached to the worker nodes"
  value       = module.eks.node_security_group_id
}
