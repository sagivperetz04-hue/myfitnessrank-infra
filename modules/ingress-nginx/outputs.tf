output "load_balancer_hostname" {
  description = "NLB DNS name fronting the ingress controller (consumed by dns-records)"
  value       = data.kubernetes_service.controller.status[0].load_balancer[0].ingress[0].hostname
}
