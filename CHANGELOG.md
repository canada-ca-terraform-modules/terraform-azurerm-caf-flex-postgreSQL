# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## v1.2.0 - 2026-08-11

### Changed

- Upgraded `azurerm` provider constraint from `~> 4.0` to `~> 5.0` (provider v5.0.1).
- Bumped the `private_endpoint` child module reference from `v1.1.0` to `v1.2.0`
  (that release already targets `azurerm ~> 5.0`).
- Bumped this module's own self-referencing ref in `ESLZ/flex_postgre_sql.tf`
  from `v1.1.0` to `v1.2.0`.
- Bumped stale GitHub Actions pins: `actions/checkout` to `v7.0.1`,
  `hashicorp/setup-terraform` to `v4.0.1`, `tflint_version` to `v0.64.0`.

### Added

- `.github/workflows/release.yml` — creates a GitHub release on merge to `main`,
  tagged from the version pinned in `ESLZ/flex_postgre_sql.tf`.

### Known blockers

- `v1.1.0` was referenced by `ESLZ/flex_postgre_sql.tf` and the `terraform-ci`
  history but was never actually tagged (no release automation existed before
  this change). This upgrade targets `v1.2.0` directly; `v1.1.0` was never
  published as a release.

### Notes

- No `azurerm` resource arguments used by this module (`azurerm_postgresql_flexible_server`,
  `azurerm_postgresql_flexible_server_database`, `azurerm_postgresql_flexible_server_configuration`,
  `azurerm_postgresql_flexible_server_active_directory_administrator`,
  `azurerm_postgresql_flexible_server_firewall_rule`, `azurerm_user_assigned_identity`,
  `azurerm_key_vault_key`, `azurerm_key_vault_secret`, `azurerm_role_assignment`)
  are present in the azurerm 5.0 upgrade guide's breaking-changes list — this is a
  version-constraint and housekeeping upgrade only, with no compat shims required.

## v1.1.0 - 2026-04-02

### Changed

- Upgraded `azurerm` provider constraint to `~> 4.0`.
- Added explicit `create_mode`, `password_auth_enabled`, `storage_tier`, and
  `auto_grow_enabled` support.
- Unique Key Vault secret name per server; fixed tfvars key mismatch; removed
  unused field.

## v1.0.0 - 2026-04-02

### Added

- Initial release of the flexible PostgreSQL Server CAF module.
