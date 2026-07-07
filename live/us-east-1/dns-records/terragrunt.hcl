include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/dns-records"
}

dependency "dns" {
  config_path = "../../global/dns"

  mock_outputs = {
    zone_id = "Z00000000000000000000"
    domain  = "mock.example"
  }
  # destroy included so teardown of a partially-applied stack (ingress not up)
  # can still resolve these and no-op instead of aborting the whole run.
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "ingress" {
  config_path = "../ingress-nginx"

  mock_outputs = {
    load_balancer_hostname = "mock.elb.us-east-1.amazonaws.com"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

inputs = {
  domain      = dependency.dns.outputs.domain
  zone_id     = dependency.dns.outputs.zone_id
  lb_hostname = dependency.ingress.outputs.load_balancer_hostname
}
