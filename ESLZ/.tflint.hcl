config {
  call_module_type = "local"
  force            = false
}

# ESLZ files are blueprint fragments copied into L2 callers, not standalone modules.
# The caller's root module provides the required_version constraint.
rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}
