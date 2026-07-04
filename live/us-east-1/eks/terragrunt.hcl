include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-00000000"
    private_subnet_ids = ["subnet-00000000", "subnet-11111111"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  cluster_name       = "myfitnessrank"
  kubernetes_version = "1.36"

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  node_instance_types = ["t3.medium"]
  node_min            = 2
  node_max            = 3
  node_desired        = 2
}
