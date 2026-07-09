variable "name" {
  description = "Bucket name (must be globally unique)"
  type        = string
}

variable "retention_days" {
  description = "Days to keep each backup object before lifecycle expiry"
  type        = number
  default     = 30
}
