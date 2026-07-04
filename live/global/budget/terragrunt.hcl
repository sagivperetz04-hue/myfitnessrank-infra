include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/budget"
}

inputs = {
  name              = "myfitnessrank-monthly"
  monthly_limit_usd = "50"

  alert_amounts_usd = [5, 10, 20, 35, 45]
  alert_emails      = ["sagivperetz04@gmail.com"]
}
