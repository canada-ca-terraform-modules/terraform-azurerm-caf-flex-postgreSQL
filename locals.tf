locals {
  resource_group_name = strcontains(var.flex_postgresql_server.resource_group, "/resourceGroups/") ? regex("[^\\/]+$", var.flex_postgresql_server.resource_group) :  var.resource_groups[var.flex_postgresql_server.resource_group].name
  kv_resource_group_name = strcontains(var.flex_postgresql_server.key_vault_group, "/resourceGroups/") ? regex("[^\\/]+$", var.flex_postgresql_server.key_vault_group) :  var.resource_groups[var.flex_postgresql_server.key_vault_group].name
}