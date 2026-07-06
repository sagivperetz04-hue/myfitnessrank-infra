output "zone_id" {
  description = "Hosted zone ID (consumed by acm validation and dns-records)"
  value       = aws_route53_zone.this.zone_id
}

output "domain" {
  description = "The apex domain, re-exported so downstream units read it from one source"
  value       = var.domain
}

output "name_servers" {
  description = "Paste these four NS records into the external registrar once"
  value       = aws_route53_zone.this.name_servers
}
