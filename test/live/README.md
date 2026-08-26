# Live test harness

Per-PR live-infrastructure check for `terraform-azurerm-caf-flex-postgreSQL`,
run by `.github/workflows/live-test.yml`. Every PR applies the target
branch's `test/live/` as a live baseline, then plans+applies the PR branch's
checkout of the same harness against that same live state, classifies the
diff, comments, and destroys - authenticated via OIDC against the shared
sandbox subscription.

## Dependencies

`test_dependencies.tf` creates a throwaway resource group + Key Vault
(RBAC-authorized, purge-protected) owned entirely by this harness, suffixed
with `var.pr_number` so concurrently open PRs never collide. The module
creates a Customer Managed Key + secret + a "Key Vault Crypto Officer" role
assignment against that Key Vault at apply time.

No subnet/private DNS zone is provisioned - `delegate_subnet_id`,
`delegate_private_dns_zone_id`, and `private_endpoint` are all optional
module inputs and are left unset in `config/flex_postgresql.tfvars`;
`public_network_access_enabled = true` is used instead to keep the harness
self-contained.

## Manual run

```bash
cd test/live
terraform init -backend-config="path=/tmp/flex-postgresql-live-test.tfstate"
terraform apply -var-file=config/flex_postgresql.tfvars
terraform destroy -var-file=config/flex_postgresql.tfvars
```
