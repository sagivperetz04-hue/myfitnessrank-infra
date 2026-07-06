variable "domain" {
  description = "Apex domain for the public site (e.g. myfitnessrank.com)"
  type        = string

  validation {
    condition     = !strcontains(var.domain, "REPLACE-ME")
    error_message = "Set the real domain in live/global/dns/terragrunt.hcl before applying."
  }
}
