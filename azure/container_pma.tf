
resource "azurerm_container_app" "phpmyadmin" {
  name                         = "ulake-phpmyadmin"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.ulake_rg.name
  revision_mode                = "Single"

  template {
    container {
      name  = "ulake-phpmyadmin"
      image = "phpmyadmin:latest"

      cpu    = "0.5"
      memory = "1Gi"

      env {
        name  = "PMA_HOST"
        value = azurerm_mysql_flexible_server.mysql.fqdn
      }
      env {
        name  = "PMA_PORT"
        value = "3306"
      }
      env {
        name  = "MYSQL_ROOT_PASSWORD"
        value = var.mysql_admin_password
      }
      env {
        name  = "MYSQL_ROOT_USER"
        value = "${var.mysql_admin_name}@${azurerm_mysql_flexible_server.mysql.name}"
      }
    }
  }

  depends_on = [azurerm_container_app_environment.env]
}
