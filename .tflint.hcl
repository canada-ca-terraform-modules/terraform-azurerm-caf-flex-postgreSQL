config {
  call_module_type = "local"
  force            = false
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

# group, project, user_data are part of the standard L2 module interface and are
# passed in by ESLZ callers. They are intentionally declared without local usage.
rule "terraform_unused_declarations" {
  enabled = false
}
