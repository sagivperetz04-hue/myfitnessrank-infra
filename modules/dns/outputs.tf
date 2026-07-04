output "zone_id" {
  description = "Hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Set these as the NS records at the domain registrar"
  value       = aws_route53_zone.this.name_servers
}
