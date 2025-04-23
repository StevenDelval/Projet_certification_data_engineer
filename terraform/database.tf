resource "azurerm_mssql_server" "sql_server" {
  name                         = "my-sqlserver-sd"
  resource_group_name          = azurerm_resource_group.resource_group.name
  location                     = azurerm_resource_group.resource_group.location
  version                      = "12.0"
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password 
}

resource "azurerm_mssql_database" "db_control_table" {
  name           = "databaseControlTables"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "Free"
  zone_redundant = false
  storage_account_type = "Local"
  geo_backup_enabled = false
}

resource "azurerm_mssql_firewall_rule" "allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "null_resource" "initialize_db" {
  provisioner "local-exec" {
    command = <<EOT
      sqlcmd -S my-sqlserver-sd.database.windows.net -U ${var.admin_login} -P "${var.admin_password}" -d ${azurerm_mssql_database.db_control_table.name} -i ../base_de_donnees/control_tables.sql
    EOT
  }
  depends_on = [azurerm_mssql_database.db_control_table]
}

resource "null_resource" "procedure" {
  provisioner "local-exec" {
    command = <<EOT
      sqlcmd -S ${azurerm_mssql_server.sql_server.name}.database.windows.net -U ${var.admin_login} -P "${var.admin_password}" -d ${azurerm_mssql_database.db_control_table.name} -i ../base_de_donnees/ct_storage_procedure.sql
    EOT
  }
  depends_on = [azurerm_mssql_database.db_control_table]
}

resource "azurerm_postgresql_flexible_server" "postgres_server" {
  name                   = "my-postgresql-sd"
  resource_group_name    = azurerm_resource_group.resource_group.name
  location               = azurerm_resource_group.resource_group.location
  administrator_login    = var.admin_login
  administrator_password = var.admin_password
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  version                       = "13"
  public_network_access_enabled = true
  storage_tier                  = "P4"
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      zone,
    ]
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall_rule" {
  name             = "postgresql-rule"
  server_id        = azurerm_postgresql_flexible_server.postgres_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"

}

resource "azurerm_postgresql_flexible_server_database" "db_data" {
  name      = "databaseDataToExpose"
  server_id = azurerm_postgresql_flexible_server.postgres_server.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "null_resource" "create_table" {
  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD="${var.admin_password}" psql -h ${azurerm_postgresql_flexible_server.postgres_server.fqdn} -U ${var.admin_login} -d ${azurerm_postgresql_flexible_server_database.db_data.name} -f ../base_de_donnees/table_data.sql
    EOT
  }
  depends_on = [azurerm_postgresql_flexible_server_database.db_data]
}