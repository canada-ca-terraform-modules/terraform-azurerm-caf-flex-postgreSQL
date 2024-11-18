resource "azurerm_user_assigned_identity" "pgsql" {
  name                = "${local.postgre-sql-server-name}-msi"
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_postgresql_flexible_server" "server" {
  name                = local.postgre-sql-server-name
  location            = var.location
  resource_group_name = local.resource_group_name

  delegated_subnet_id = try(var.flex_postgresql_server.delegate_subnet_id, null)
  private_dns_zone_id = try(var.flex_postgresql_server.delegate_private_dns_zone_id, null)
  
  public_network_access_enabled = try(var.flex_postgresql_server.public_network_access_enabled, false)
  administrator_login           = try(var.flex_postgresql_server.administrator_login, "psqladmin")
  administrator_password        = azurerm_key_vault_secret.password.value

  sku_name = var.flex_postgresql_server.sku_name
  version  = var.flex_postgresql_server.version
  storage_mb = try(var.flex_postgresql_server.storage.storage_mb, 32768)

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.pgsql.id]
  }

  authentication {
    active_directory_auth_enabled = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  customer_managed_key {
    key_vault_key_id                  = azurerm_key_vault_key.key.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.pgsql.id
  }

  backup_retention_days        = try(var.flex_postgresql_server.backup_retention_days, 7)
  geo_redundant_backup_enabled = try(var.flex_postgresql_server.geo_redundant_backup_enabled,false) # Geo-backup disabled for CMK compatibility

  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags,
      zone
    ]
  }
}



resource "azurerm_postgresql_flexible_server_database" "db" {
  for_each = var.flex_postgresql_server.postgresql_databases
  name                = each.key
  server_id         = azurerm_postgresql_flexible_server.server.id
  charset             = each.value.charset
  collation           = each.value.collation

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}



resource "azurerm_postgresql_flexible_server_configuration" "config" {
  for_each = try(var.flex_postgresql_server.postgre_sql_configuration, {})
  name                = each.key
  server_id        = azurerm_postgresql_flexible_server.server.id
  value               = each.value
}



resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  for_each = try(var.flex_postgresql_server.ad_administrators, {})
  server_name         = azurerm_postgresql_flexible_server.server.name
  resource_group_name = local.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = each.value.adadmin_object_id
  principal_name      = each.value.principal_name
  principal_type      = each.value.principal_type
}


resource "azurerm_postgresql_firewall_rule" "firewall" {
  for_each = try(var.flex_postgresql_server.firewalls, {})
  name                = "${local.postgre-sql-server-name}-${each.key}-fw"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.server.name
  start_ip_address    = var.flex_postgresql_server.firewall.start_ip_address
  end_ip_address      = var.flex_postgresql_server.firewall.end_ip_address
}



resource "azurerm_role_assignment" "key_vault_role_assignment" {
  scope                = var.key_vault.id
  role_definition_name = "Key Vault Crypto Officer"  # Use the role you need
  principal_id         = azurerm_user_assigned_identity.pgsql.principal_id

}

resource "azurerm_key_vault_key" "key" {
  name         = "${local.postgre-sql-server-name}-psql-key"
  key_vault_id = var.key_vault.id
  key_type     = var.flex_postgresql_server.managed_key.key_type
  key_size     = var.flex_postgresql_server.managed_key.key_size
  key_opts     = var.flex_postgresql_server.managed_key.key_opts
  depends_on = [
    azurerm_role_assignment.key_vault_role_assignment,

  ]

}





# Calls this module if we need a private endpoint attached to the storage account
module "private_endpoint" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-private_endpoint.git?ref=v1.0.2"
  for_each =  try(var.flex_postgresql_server.private_endpoint, {}) 

  name = "${local.postgre-sql-server-name}-${each.key}"
  location = var.location
  resource_groups = var.resource_groups
  subnets = var.subnets
  private_connection_resource_id = azurerm_postgresql_flexible_server.server.id
  private_endpoint = each.value
  private_dns_zone_ids = var.private_dns_zone_ids
  tags = var.tags
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault.name
  resource_group_name = local.kv_resource_group_name
}



resource "random_password" "generated_password" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "password" {
  name         = "psql-admin-password"
  value        = random_password.generated_password.result
  key_vault_id = var.key_vault.id
}



data "azurerm_client_config" "current" {}



