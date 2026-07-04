variable "domain" {
  description = "Root domain for the hosted zone (e.g. myfitnessrank.com)"
  type        = string
}

variable "cname_records" {
  description = "Subdomain -> target map (e.g. staging -> the ingress NLB hostname)"
  type        = map(string)
  default     = {}
}
