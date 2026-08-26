variable "env" {
  description = "Environment prefix used in the generated server/RG/KV names"
  type        = string
  default     = "livetest"
}

variable "group" {
  description = "(Required by the module) group portion of the generated name"
  type        = string
  default     = "test"
}

variable "project" {
  description = "(Required by the module) project portion of the generated name"
  type        = string
  default     = "test"
}

variable "location" {
  description = "Location for the throwaway live-test resource group"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to resources created by this harness"
  type        = map(string)
  default = {
    purpose = "module-live-test"
  }
}

variable "pr_number" {
  description = <<-EOT
    Suffix applied to test_dependencies.tf resource names so concurrent PRs
    against this module never collide on the same sandbox subscription. CI
    sources this from `TF_VAR_pr_number` (`github.event.number`); manual runs
    can leave the default or pass their own value.
  EOT
  type        = string
  default     = "manual"
}

variable "flex_postgresql_server" {
  description = "flex_postgresql_server configuration object, passed straight through to the module under test"
  type        = any
}
