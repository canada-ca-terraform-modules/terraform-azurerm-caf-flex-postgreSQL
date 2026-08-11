variable "location" {
  description = "Azure location for the VM"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags that will be applied to every associated VM resource"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) 4 character string defining the environment name prefix for the VM"
  type        = string
  default     = "dev"
}

variable "group" {
  description = "(Required) Character string defining the group for the target subscription"
  type        = string
  default     = "test"
  #tflint-ignore: terraform_unused_declarations
}

variable "project" {
  description = "(Required) Character string defining the project for the target subscription"
  type        = string
  default     = "test"
  #tflint-ignore: terraform_unused_declarations
}

variable "userDefinedString" {
  description = "(Required) User defined portion value for the name of the VM."
  type        = string
  default     = "test"
}





variable "private_dns_zone_ids" {
  description = "(Optional) DNS configuration for the flexible postgre SQL server. Only used when delegate_subnet_id is set."
  type        = any
  default     = null
}



variable "flex_postgresql_server" {
  description = "(Required) configuration for the postgre SQL server."
  type        = any
  default     = null
}

variable "resource_groups" {
  description = "(Required) Resource group object for the flexible postgre SQL server."
  type        = any
  default     = {}
}



variable "subnets" {
  description = "(Required) List of subnet objects for the postgre SQL server."
  type        = any
  default     = {}
}

variable "key_vault" {
  description = "(Required) List of key vault objects for the postgre SQL server."
  type        = any
  default     = {}
}

variable "user_data" {
  description = "Base64 encoded file representing user data script for the VM. Unused by this module - kept for interface parity with sibling CAF VM modules."
  type        = any
  default     = null
  #tflint-ignore: terraform_unused_declarations
}
