resource "azurerm_mssql_server" "sql_server" {
  name                         = "my-sqlserver-sd"
  resource_group_name          = azurerm_resource_group.resource_group.name
  location                     = azurerm_resource_group.resource_group.location
  version                      = "12.0"
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
}

resource "azurerm_mssql_database" "db" {
  name           = "databaseControlTables"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "Free"
  zone_redundant = false
  storage_account_type = "Local"
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
      sqlcmd -S my-sqlserver-sd.database.windows.net -U ${var.admin_login} -P "${var.admin_password}" -d databaseControlTables -i ../base_de_donnees/control_tables.sql
    EOT
  }
  depends_on = [azurerm_mssql_database.db]
}

resource "null_resource" "procedure" {
  provisioner "local-exec" {
    command = <<EOT
      sqlcmd -S my-sqlserver-sd.database.windows.net -U ${var.admin_login} -P "${var.admin_password}" -d databaseControlTables -i ../base_de_donnees/ct_storage_procedure.sql
    EOT
  }
  depends_on = [azurerm_mssql_database.db]
}