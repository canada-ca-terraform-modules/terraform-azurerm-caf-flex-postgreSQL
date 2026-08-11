flex_postgre_sql_servers = {
  server1 = {
    resource_group  = "Project"
    key_vault_group = "Keyvault"
    # delegate_subnet_id = "/subscriptions/edc8d26f-9061-4fef-9e99-019ade8ba930/resourceGroups/G3Dc-CTO_Test1_Network-rg/providers/Microsoft.Network/virtualNetworks/G3DcCNR-CTO_Test1-vnet/subnets/postgre-sql" #(Optional) The ID of the virtual network subnet to create the PostgreSQL Flexible Server. The provided subnet should not have any other resource deployed in it and this subnet will be delegated to the PostgreSQL Flexible Server, if not already delegated. Changing this forces a new PostgreSQL Flexible Server to be created.
    # delegate_private_dns_zone_id = "/subscriptions/edc8d26f-9061-4fef-9e99-019ade8ba930/resourceGroups/G3Dc-CTO_Test1_Network-rg/providers/Microsoft.Network/privateDnsZones/privatelink.postgres.database.azure.com" # (Optional) The ID of the private DNS zone to create the PostgreSQL Flexible Server.
    sku_name                      = "GP_Standard_D4s_v3"
    administrator_login           = "psqladmin"
    storage_mb                    = 32768 #Max storage allowed for a server. Possible values are 32768 MB(32GiB), 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 and 33553408.
    backup_retention_days         = 7
    geo_redundant_backup_enabled  = false
    create_mode                   = "Default"
    # source_server_id             = null #(Optional) For creation modes other than Default, the source server ID to use.
    public_network_access_enabled = false
    zone                          = "1" #(Optional) Specifies the Availability Zone in which this MySQL Flexible Server should be located. Possible values are 1, 2 and 3.
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

    postgre_sql_configuration = { #Specifies the value of the PostgreSQL Configuration. See the PostgreSQL documentation for valid values. Changing this forces a new resource to be created.
      "azure.extensions"                      = "POSTGIS,PGCRYPTO"
      "client_min_messages"                   = "log"
      "debug_pretty_print"                    = "on"
      "debug_print_parse"                     = "off"
      "debug_print_plan"                      = "off"
      "debug_print_rewritten"                 = "off"
      "log_checkpoints"                       = "on"
      "log_duration"                          = "off"
      "log_error_verbosity"                   = "verbose"
      "log_line_prefix"                       = "%m [%p] %q[user=%u,db=%d,app=%a,client=%h] "
      "log_lock_waits"                        = "off"
      "log_min_duration_statement"            = "10"
      "log_min_error_statement"               = "error"
      "log_min_messages"                      = "warning"
      "log_statement"                         = "ddl"
      "row_security"                          = "on"
      "checkpoint_warning"                    = "0"
      "connection_throttle.enable"            = "on"
      "maintenance_work_mem"                  = "32000"
      "min_wal_size"                          = "512"
      "max_wal_size"                          = "512"
      "pg_stat_statements.track_utility"      = "off"
      "pg_qs.track_utility"                   = "off"
      "pg_qs.query_capture_mode"              = "top"
      "pgaudit.log"                           = "ddl"
      "pgms_wait_sampling.query_capture_mode" = "all"
      "temp_buffers"                          = "16384"
      "wal_buffers"                           = "8192"
      "wal_writer_delay"                      = "200"
      "wal_writer_flush_after"                = "128"
      "work_mem"                              = "2048000"
    }
    version = "16"
    postgresql_databases = {
      test = {
        charset   = "UTF8"
        collation = "en_US.utf8"
      }

    }



    private_endpoint = {
      postgresqlServer = {                       # Key defines the userDefinedstring
        resource_group    = "Project"            # Required: Resource group name, i.e Project, Management, DNS, etc, or the resource group ID
        subnet            = "OZ"                 # Required: Subnet name, i.e OZ,MAZ, etc, or the subnet ID
        subresource_names = ["postgresqlServer"] # Required: Subresource name determines to what service the private endpoint will connect to. see: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource for list of subresrouce
        # local_dns_zone    = "privatelink.postgresqlServer.core.windows.net" # Optional: Name of the local DNS zone for the private endpoint
      }
    }

    firewall_rules = {
      rule1 = {
        start_ip_address = "0.0.0.0"
        end_ip_address   = "255.255.255.255"
      }
    }
    managed_key = { #Manages a Customer Managed Key for a PostgreSQL Server

      key_type = "RSA"
      key_size = 2048
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

    }

    # New in azurerm >= 4.x: explicit create mode (Default, GeoRestore, PointInTimeRestore, Replica, ReviveDropped, Update)
    create_mode = "Default"
    # source_server_id = "/subscriptions/.../flexibleServers/source-server" # Required for GeoRestore, PointInTimeRestore, Replica

    # New in azurerm >= 4.x: password authentication toggle (set false for AAD-only access)
    # password_auth_enabled = false

    # New in azurerm >= 4.x: storage performance tier (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80)
    # storage_tier = "P10"

    # New in azurerm >= 4.x: auto-grow storage when nearing capacity
    # auto_grow_enabled = true

  }
}
