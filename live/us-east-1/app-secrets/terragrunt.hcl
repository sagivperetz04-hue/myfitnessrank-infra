include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/app-secrets"

  # Orphaned aggregated APIServices (e.g. prometheus-adapter's custom/external
  # metrics) outlive their backing Service on teardown. A stale APIService
  # breaks cluster API discovery, which wedges namespace deletion and hangs
  # `destroy`. Clear them before this unit deletes its namespaces. Best-effort:
  # an unreachable cluster or absent APIService must never block the teardown.
  before_hook "clear_stale_apiservices" {
    commands = ["destroy"]
    execute = [
      "bash", "-c",
      <<-EOT
        kubeconfig=$(mktemp)
        aws eks update-kubeconfig --name ${dependency.eks.outputs.cluster_name} --region ${include.root.locals.aws_region} --kubeconfig "$kubeconfig" >/dev/null 2>&1 || exit 0
        kubectl --kubeconfig "$kubeconfig" delete apiservice v1beta1.custom.metrics.k8s.io v1beta1.external.metrics.k8s.io --ignore-not-found >/dev/null 2>&1 || true
        rm -f "$kubeconfig"
      EOT
    ]
  }
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
