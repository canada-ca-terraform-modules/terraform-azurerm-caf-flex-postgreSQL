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

# Upgrade compatibility — verifies that existing callers using the v1.0.0 tfvars
# format continue to produce a valid plan without modification.

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
  userDefinedString    = "server1"
  location             = "canadacentral"
  tags                 = {}
  key_vault = {
    id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/test-kv"
    name = "test-kv"
  }
  flex_postgresql_server = {
    resource_group                = "Project"
    key_vault_group               = "Keyvault"
    sku_name                      = "GP_Standard_D4s_v3"
    administrator_login           = "psqladmin"
    storage_mb                    = 32768
    backup_retention_days         = 7
    geo_redundant_backup_enabled  = false
    create_mode                   = "Default"
    public_network_access_enabled = false
    version                       = "16"
    managed_key = {
      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    }
    ad_administrators = {
      admin1 = {
        adadmin_object_id = "8f9f455a-2c2c-421a-a409-c65413727c9b"
        principal_name    = "GcPc-Terraform-ENT-automation-deploy"
        principal_type    = "ServicePrincipal"
      }
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
    postgresql_databases = {
      test = { charset = "UTF8", collation = "en_US.utf8" }
    }
  }
}

run "existing_caller_format_still_plans" {
  command = plan

  assert {
    condition     = azurerm_postgresql_flexible_server.server.name == "dev-server1-flex-psql"
    error_message = "Existing v1.0.0 caller format must still produce correct name"
  }

  assert {
    condition     = azurerm_postgresql_flexible_server.server.create_mode == "Default"
    error_message = "create_mode from v1.0.0 tfvars must be forwarded to the resource"
  }
}
