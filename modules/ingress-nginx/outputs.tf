output "namespace" {
  description = "Namespace ingress-nginx was installed into"
  value       = helm_release.ingress_nginx.namespace
}
