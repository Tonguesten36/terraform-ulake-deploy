resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "ulake-mysql"
  resource_group_name    = azurerm_resource_group.ulake_rg.name
  location               = var.location
  administrator_login    = var.mysql_admin_name
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"

  delegated_subnet_id = azurerm_subnet.mysql_subnet.id

  storage {
    size_gb = 20
  }
  backup_retention_days = 7

  depends_on = [azurerm_subnet.mysql_subnet, azurerm_virtual_network.ulake_vnet]
}

resource "azurerm_mysql_flexible_database" "ulake_log_db" {
  name                = "ulake-log"
  server_name         = azurerm_mysql_flexible_server.mysql.name
  resource_group_name = azurerm_resource_group.ulake_rg.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  depends_on = [azurerm_mysql_flexible_server.mysql]
}

resource "azurerm_mysql_flexible_database" "ulake_user_db" {
  name                = "ulake-user"
  server_name         = azurerm_mysql_flexible_server.mysql.name
  resource_group_name = azurerm_resource_group.ulake_rg.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  depends_on = [azurerm_mysql_flexible_server.mysql]
}

# Consider using cli instead of manually create database
# az mysql flexible-server execute \
#     --name <server_name> \
#     --admin-user <username> \
#     --admin-password <password> \
#     --database-name <database_name> \
#     --file-path script.sql


# It allows your MySQL server to be accessed via a consistent hostname (ulake-mysql.privatelink.mysql.database.azure.com)
# rather than relying on a potentially changing private IP address
resource "azurerm_private_dns_zone" "mysql_dns_zone" {
  resource_group_name = azurerm_resource_group.ulake_rg.name
  name = "ulake-mysql.privatelink.mysql.database.azure.com"
}

resource "azurerm_private_dns_zone_virtual_network_link" "ulake_dns_zone_link" {
  virtual_network_id = azurerm_virtual_network.ulake_vnet.id
  resource_group_name = azurerm_resource_group.ulake_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns_zone.name
  name = "ulake_dns_zone_link"
}