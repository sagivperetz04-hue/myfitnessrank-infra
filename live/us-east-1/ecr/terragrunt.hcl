include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Persistent foundation: the image registry must survive stopinfra so pushed
# images aren't lost on every teardown. Skipped by routine `run --all destroy`;
# destroy explicitly (cd here && terragrunt destroy) if ever truly needed.
exclude {
  if      = true
  actions = ["destroy"]
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
