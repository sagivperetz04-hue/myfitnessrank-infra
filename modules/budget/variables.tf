variable "name" {
  description = "Budget name"
  type        = string
}

variable "monthly_limit_usd" {
  description = "Monthly cost limit in USD"
  type        = string
}

variable "alert_amounts_usd" {
  description = "Dollar amounts of actual spend that trigger an alert email (AWS allows max 5 notifications per budget)"
  type        = list(number)

  validation {
    condition     = length(var.alert_amounts_usd) <= 5
    error_message = "AWS Budgets allows at most 5 notifications per budget."
  }
}

variable "alert_emails" {
  description = "Email addresses that receive budget notifications"
  type        = list(string)
}
