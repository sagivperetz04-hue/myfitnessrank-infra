variable "domain" {
  description = "Apex domain (records created: apex, staging.<domain>, www.<domain>)"
  type        = string
}

variable "zone_id" {
  description = "Hosted zone ID the records are created in"
  type        = string
}

variable "lb_hostname" {
  description = "NLB DNS name from the ingress-nginx unit — orders this unit after the LB exists and cross-checks the tag lookup"
  type        = string
}
