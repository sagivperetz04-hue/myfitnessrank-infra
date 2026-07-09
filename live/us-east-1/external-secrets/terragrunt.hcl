include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/external-secrets"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "myfitnessrank"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

# Ordering only: the secret values must exist in Secrets Manager before the
# operator starts resolving ExternalSecrets against them.
dependency "app_secret_values" {
  config_path  = "../../global/app-secret-values"
  skip_outputs = true
}

inputs = {
  cluster_name  = dependency.eks.outputs.cluster_name
  chart_version = "2.7.0"
  project       = "myfitnessrank"
}
