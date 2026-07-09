variable "project" {
  description = "Prefix for the Secrets Manager secret names"
  type        = string
}

variable "environments" {
  description = "Environments to hold a consolidated app secret for"
  type        = list(string)
  default     = ["staging", "prod"]
}
