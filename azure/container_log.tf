
resource "azurerm_container_app" "log_service" {
  name                         = "ulake-service-log"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.ulake_rg.name
  revision_mode                = "Single"

  template {
    container {
      name  = "ulake-service-log"
      image = "${azurerm_container_registry.acr.login_server}/ulake-service-log:latest"

      cpu    = "0.5"
      memory = "1Gi"

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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ulake_container_identity.id]
  }

  ingress {
    external_enabled = false
    target_port = 8790
    transport = "http"
    traffic_weight {
      percentage = 100 
      latest_revision = true
    }
  }

  depends_on = [
    azurerm_container_app_environment.env,
    azurerm_storage_account.ulake_store,
    azurerm_user_assigned_identity.ulake_container_identity
  ]
}
