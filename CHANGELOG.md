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
- Verified `azurerm_postgresql_flexible_server_active_directory_administrator`'s
  `server_name`/`resource_group_name` arguments remain valid (not deprecated in
  favour of a `server_id`) against the azurerm 5.0.1 provider docs.

### Fixed (review follow-up)

- `zone` is now forwarded from `flex_postgresql_server.zone` instead of being
  silently dropped (initial placement only — `lifecycle.ignore_changes` still
  covers drift).
- Removed `README copy.md`, a stray file containing unrelated
  `terraform-azurerm-caf-windows_clusterV2` documentation.
- `random_password.generated_password` now enforces `min_lower`/`min_upper`/
  `min_numeric`/`min_special` so generated passwords can't fail Azure's
  complexity policy at deploy time.
- `azurerm_key_vault_secret.password` now sets `content_type`.
- Replaced the any-to-any (`0.0.0.0` → `255.255.255.255`) example firewall
  rule in `ESLZ/flex_postgre_sql.tfvars` with a representative private range.
- Clarified `private_dns_zone_ids`'s description (was mislabeled `(Required)`
  despite defaulting to `null` and being genuinely optional) and documented
  why `user_data` is accepted but unused.
- `release.yml`'s version-extraction regex is now anchored to this module's
  own source line instead of matching the first `vX.Y.Z` ref in the file, and
  the PR body used as release notes is now length-truncated.
- `terraform-ci.yml`'s `terraform test` step now passes `-test-directory=tests`
  explicitly.

## v1.1.0 - 2026-04-02

### Changed

- Upgraded `azurerm` provider constraint to `~> 4.0`.
- Added explicit `create_mode`, `password_auth_enabled`, `storage_tier`, and
  `auto_grow_enabled` support.
- Unique Key Vault secret name per server; fixed tfvars key mismatch; removed
  unused field.

## v1.0.0 - 2025-05-26

### Added

- Initial release of the flexible PostgreSQL Server CAF module.
