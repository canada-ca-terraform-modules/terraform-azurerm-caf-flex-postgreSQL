# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# terraform-azurerm-caf-flex-postgreSQL needs: a resource group (looked up by
# name via var.resource_groups[key].name) and an existing Key Vault
# (var.key_vault.id) - the module itself creates a Customer Managed Key +
# secret + a "Key Vault Crypto Officer" role assignment against that Key
# Vault, so the Key Vault must have RBAC authorization enabled and purge
# protection on (required by Azure for CMK-encrypted Postgres Flexible
# Servers). No vnet/subnet is provisioned - delegate_subnet_id and
# private_endpoint are left unset in config/flex_postgresql.tfvars (both
# optional), so the server uses public_network_access_enabled = true
# instead to keep the harness self-contained.

resource "azurerm_resource_group" "live_test" {
  # pr-number suffix keeps two concurrently open PRs against this module from
  # colliding on the same sandbox subscription.
  name     = "${var.env}-caf-flex-postgresql-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag: lets the nightly orphan sweeper find this RG by tag and
  # match it back to a PR, independent of naming convention.
  tags = merge(var.tags, {
    "pr-number" = var.pr_number
  })
}

resource "azurerm_key_vault" "live_test" {
  # Key Vault names cap at 24 chars - keep the fixed prefix/suffix short so
  # pr_number (a GitHub PR number in CI, e.g. "123") always fits.
  name                       = substr(lower("fpglt${var.pr_number}kv"), 0, 24)
  location                   = azurerm_resource_group.live_test.location
  resource_group_name        = azurerm_resource_group.live_test.name
  tenant_id                  = data.azurerm_client_config.live_test.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  tags                       = var.tags
}

# The identity running terraform plan/apply also needs to read/write keys
# and secrets directly against this Key Vault (Terraform's own provider
# calls, separate from the module's own "Key Vault Crypto Officer" grant to
# the Postgres server's UAI at runtime) - granted here since it's this
# harness's own throwaway Key Vault, not a shared/production one.
resource "azurerm_role_assignment" "deployer_kv_admin" {
  scope                = azurerm_key_vault.live_test.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.live_test.object_id
}

# Azure RBAC role assignments can take a couple of minutes to propagate to
# Key Vault's own data-plane authorization check - without this delay, the
# module's first key_vault_key/key_vault_secret read can 403 even though the
# role assignment above already exists.
resource "time_sleep" "kv_rbac_propagation" {
  depends_on      = [azurerm_role_assignment.deployer_kv_admin]
  create_duration = "120s"
}

data "azurerm_client_config" "live_test" {}

locals {
  resource_groups = {
    live_test = { name = azurerm_resource_group.live_test.name }
  }
  key_vault = { id = azurerm_key_vault.live_test.id }
}
