include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/backups-bucket"
}

inputs = {
  name           = "myfitnessrank-db-backups-${get_aws_account_id()}"
  retention_days = 30
}
