include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/acm"
}

dependency "dns" {
  config_path = "../../global/dns"

  mock_outputs = {
    zone_id = "Z00000000000000000000"
    domain  = "mock.example"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  domain  = dependency.dns.outputs.domain
  zone_id = dependency.dns.outputs.zone_id
}
