mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      subscription_id = "00000000-0000-0000-0000-000000000002"
      client_id       = "00000000-0000-0000-0000-000000000003"
      object_id       = "00000000-0000-0000-0000-000000000004"
    }
  }
  mock_data "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/test-kv"
    }
  }
}
mock_provider "random" {}

variables {
  resource_groups = {
    Project  = { name = "rg-project", location = "canadacentral" }
    Keyvault = { name = "rg-keyvault", location = "canadacentral" }
  }
  subnets              = {}
  private_dns_zone_ids = null
  env                  = "dev"
  group                = "test"
  project              = "test"
  userDefinedString    = "psql"
  location             = "canadacentral"
  tags                 = {}
  key_vault = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/test-kv"
    name = "test-kv"
  }
}

run "naming_convention" {
  command = plan

  variables {
    flex_postgresql_server = {
      resource_group  = "Project"
      key_vault_group = "Keyvault"
      sku_name        = "GP_Standard_D4s_v3"
      version         = "16"
      managed_key = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      }
      postgresql_databases = {
        testdb = { charset = "UTF8", collation = "en_US.utf8" }
      }
    }
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.server.name == "dev-psql-flex-psql"
    error_message = "Server name must follow {env}-{userDefinedString}-flex-psql convention"
  }

  assert {
    condition     = azurerm_user_assigned_identity.pgsql.name == "dev-psql-flex-psql-msi"
    error_message = "MSI name must be {server-name}-msi"
  }
}

run "default_values" {
  command = plan

  variables {
    flex_postgresql_server = {
      resource_group  = "Project"
      key_vault_group = "Keyvault"
      sku_name        = "GP_Standard_D4s_v3"
      version         = "16"
      managed_key = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      }
      postgresql_databases = {
        testdb = { charset = "UTF8", collation = "en_US.utf8" }
      }
    }
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.server.backup_retention_days == 7
    error_message = "Default backup_retention_days must be 7"
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.server.geo_redundant_backup_enabled == false
    error_message = "Default geo_redundant_backup_enabled must be false"
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.server.public_network_access_enabled == false
    error_message = "Default public_network_access_enabled must be false"
  }
}

run "high_availability_and_maintenance_window" {
  command = plan

  variables {
    flex_postgresql_server = {
      resource_group  = "Project"
      key_vault_group = "Keyvault"
      sku_name        = "GP_Standard_D4s_v3"
      version         = "16"
      managed_key = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      }
      postgresql_databases = {
        testdb = { charset = "UTF8", collation = "en_US.utf8" }
      }
      high_availability = {
        mode                      = "SameZone"
        standby_availability_zone = 1
      }
      maintenance_window = {
        day_of_week  = 1
        start_hour   = 2
        start_minute = 0
      }
    }
  }

  assert {
    condition     = length(azurerm_postgresql_flexible_server.server.high_availability) == 1
    error_message = "high_availability block must be present when configured"
  }

  assert {
    condition     = length(azurerm_postgresql_flexible_server.server.maintenance_window) == 1
    error_message = "maintenance_window block must be present when configured"
  }
}

run "firewall_rules" {
  command = plan

  variables {
    flex_postgresql_server = {
      resource_group  = "Project"
      key_vault_group = "Keyvault"
      sku_name        = "GP_Standard_D4s_v3"
      version         = "16"
      managed_key = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      }
      postgresql_databases = {
        testdb = { charset = "UTF8", collation = "en_US.utf8" }
      }
      firewall_rules = {
        rule1 = {
          start_ip_address = "10.0.0.1"
          end_ip_address   = "10.0.0.254"
        }
      }
    }
  }

  assert {
    condition     = azurerm_postgresql_flexible_server_firewall_rule.firewall["rule1"].start_ip_address == "10.0.0.1"
    error_message = "Firewall rule start_ip_address must match each.value"
  }
}

run "no_high_availability" {
  command = plan

  variables {
    flex_postgresql_server = {
      resource_group  = "Project"
      key_vault_group = "Keyvault"
      sku_name        = "GP_Standard_D4s_v3"
      version         = "16"
      managed_key = {
        key_type = "RSA"
        key_size = 2048
        key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      }
      postgresql_databases = {
        testdb = { charset = "UTF8", collation = "en_US.utf8" }
      }
    }
  }

  assert {
    condition     = length(azurerm_postgresql_flexible_server.server.high_availability) == 0
    error_message = "high_availability block must be absent when not configured"
  }
}
