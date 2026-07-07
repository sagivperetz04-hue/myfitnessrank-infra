include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Persistent foundation: the CI OIDC role must survive stopinfra so the
# AWS_ROLE_ARN GitHub secret stays valid and CI keeps pushing to ECR. Skipped
# by routine `run --all destroy`; destroy explicitly if ever truly needed.
exclude {
  if      = true
  actions = ["destroy"]
}

terraform {
  source = "${get_repo_root()}/modules/github-oidc"
}

dependency "ecr" {
  config_path = "../ecr"

  mock_outputs = {
    repository_arns = {
      mock = "arn:aws:ecr:us-east-1:000000000000:repository/mock"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  role_name         = "myfitnessrank-github-ci"
  github_repository = "sagivperetz04-hue/myfitnessrank"

  ecr_repository_arns = values(dependency.ecr.outputs.repository_arns)
}
