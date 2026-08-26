# config/flex_postgresql.tfvars
# Minimal, valid fixture exercising the module's common path.
#
# This harness deploys into its own throwaway resource group + Key Vault
# (see test_dependencies.tf) - no L1 access or shared resource group
# permissions needed, and no risk of colliding with any real resource.
#
# resource_group / sku_name / version / postgresql_databases / managed_key
# are the only attributes the module reads without a try()-default
# fallback, so they're required here. Everything else (delegate_subnet_id,
# private_endpoint, firewall_rules, ad_administrators, high_availability,
# maintenance_window, postgre_sql_configuration, storage_tier,
# auto_grow_enabled, password_auth_enabled, create_mode,
# geo_redundant_backup_enabled, backup_retention_days) is optional and
# deliberately omitted to keep this fixture minimal.

flex_postgresql_server = {
  resource_group                = "live_test"
  sku_name                      = "GP_Standard_D2s_v3"
  version                       = "16"
  public_network_access_enabled = true
  postgresql_databases          = {}

  managed_key = {
    key_type = "RSA"
    key_size = 2048
    key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  }
}
