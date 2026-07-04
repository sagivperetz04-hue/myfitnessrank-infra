output "budget_id" {
  description = "ID of the monthly cost budget"
  value       = aws_budgets_budget.monthly.id
}
