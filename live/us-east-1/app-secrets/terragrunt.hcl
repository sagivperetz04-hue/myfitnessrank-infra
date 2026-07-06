include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/app-secrets"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "myfitnessrank"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  environments = ["staging", "prod"]
}
