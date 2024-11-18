variable "flex_postgre_sql_servers" {
  type = any
  default = {}
  description = "Value for postgre sql servers. This is a collection of values as defined in postgre_sql.tfvars"
}

module "postgre_sql_server" {

    for_each = var.flex_postgre_sql_servers
    source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-flex-postgreSQL"
    location= var.location
    env = var.env
    group = var.group
    project = var.project
    userDefinedString = each.key
    flex_postgresql_server = each.value
    resource_groups = local.resource_groups_all
    subnets = local.subnets
    user_data = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
    key_vault = local.Project-kv 
    tags = var.tags
}