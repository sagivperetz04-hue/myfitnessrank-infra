output "namespace" {
  description = "Namespace ArgoCD runs in"
  value       = helm_release.argocd.namespace
}

output "root_application" {
  description = "Name of the bootstrap Application — everything else syncs from git"
  value       = "myfitnessrank-root"
}
