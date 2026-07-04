include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/ecr"
}

inputs = {
  repository_names = [
    "myfitnessrank/backend",
    "myfitnessrank/auth",
    "myfitnessrank/leaderboards",
    "myfitnessrank/frontend",
  ]
}
