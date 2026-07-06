output "records" {
  description = "FQDNs now aliased to the ingress NLB"
  value       = [for r in aws_route53_record.site : r.fqdn]
}
