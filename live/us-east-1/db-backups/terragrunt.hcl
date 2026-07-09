include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/db-backups"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "myfitnessrank"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "bucket" {
  config_path = "../../global/db-backups-bucket"

  mock_outputs = {
    arn = "arn:aws:s3:::myfitnessrank-db-backups-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  bucket_arn   = dependency.bucket.outputs.arn

  # Must match each postgres chart's <fullname>-backup ServiceAccount, which
  # the aws ApplicationSet pins via releaseName (deploy/argocd/aws/services.yaml)
  associations = [
    { namespace = "myfitnessrank-prod", service_account = "postgres-backup" },
    { namespace = "myfitnessrank-prod", service_account = "postgres-auth-backup" },
    { namespace = "myfitnessrank-prod", service_account = "postgres-leaderboards-backup" },
  ]
}
