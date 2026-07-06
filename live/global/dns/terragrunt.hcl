# The ONLY place the domain is written in this repo — every other unit reads
# it from this unit's outputs. After first apply, copy the name_servers output
# into the external registrar's NS settings (one-time; propagation up to 48h,
# usually minutes).
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/dns"
}

inputs = {
  # REPLACE-ME: set the purchased domain, e.g. "myfitnessrank.com".
  # startinfra.sh refuses to run while this placeholder is present.
  domain = "REPLACE-ME.example"
}
