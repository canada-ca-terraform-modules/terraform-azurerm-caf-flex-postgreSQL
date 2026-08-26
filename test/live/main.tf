terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {
    key_vault {
      # This harness's Key Vault is fully self-owned by Terraform - safe to
      # purge on destroy every run.
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      # This harness's resource group is fully self-owned by Terraform - no
      # risk of destroying anything not created by this run.
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "flex_postgresql" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  # Waits for the deploying principal's own Key Vault Administrator grant
  # (test_dependencies.tf) to actually propagate before touching the vault -
  # otherwise the module's key_vault_key/key_vault_secret reads 403.
  depends_on = [time_sleep.kv_rbac_propagation]

  location               = var.location
  env                    = var.env
  group                  = var.group
  project                = var.project
  userDefinedString      = "livetest"
  flex_postgresql_server = var.flex_postgresql_server
  resource_groups        = local.resource_groups
  subnets                = {}
  key_vault              = local.key_vault
  tags                   = var.tags
}
