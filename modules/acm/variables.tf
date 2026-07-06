variable "domain" {
  description = "Apex domain the certificate covers (plus *.domain as a SAN)"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID where the DNS validation records go"
  type        = string
}
