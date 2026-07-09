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

# Ordering only (no outputs consumed). Apply: namespaces + secrets must exist
# before ArgoCD deploys apps into them. Destroy: ArgoCD must be gone before
# app-secrets runs — a live ArgoCD self-heals the prometheus-adapter APIService
# right after app-secrets' clear_stale_apiservices hook deletes it, and the
# stale recreation wedges namespace deletion indefinitely.
dependency "app_secrets" {
  config_path  = "../app-secrets"
  skip_outputs = true
}

inputs = {
  cluster_name       = dependency.eks.outputs.cluster_name
  chart_version      = "10.1.2"
  apps_chart_version = "2.0.5"

  # Root Application: this cluster runs staging + prod, synced from the app
  # repo's aws app-of-apps. Dev stays on local kind (deploy/argocd/local).
  gitops_repo_url = "https://github.com/sagivperetz04-hue/myfitnessrank.git"
  gitops_revision = "master"
  gitops_path     = "deploy/argocd/aws"
}
