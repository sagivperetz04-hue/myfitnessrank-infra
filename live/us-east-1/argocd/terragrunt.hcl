include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/argocd"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "myfitnessrank"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  cluster_name  = dependency.eks.outputs.cluster_name
  chart_version = "10.1.2"

  # Root Application: this cluster runs staging + prod, synced from the app
  # repo's aws app-of-apps. Dev stays on local kind (deploy/argocd/local).
  gitops_repo_url = "https://github.com/sagivperetz04-hue/myfitnessrank.git"
  gitops_revision = "master"
  gitops_path     = "deploy/argocd/aws"
}
