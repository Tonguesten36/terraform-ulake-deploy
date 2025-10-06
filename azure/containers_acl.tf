
resource "azurerm_container_app" "acl_service" {
  name                         = "ulake-service-acl"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.ulake_rg.name
  revision_mode                = "Single"

  template {
    container {
      name  = "ulake-service-acl"
      image = "${azurerm_container_registry.acr.login_server}/ulake-service-acl:latest"

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

  ingress {
    target_port = 8785
    external_enabled = false
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ulake_container_identity.id]
  }

  depends_on = [
    azurerm_container_app_environment.env,
    azurerm_user_assigned_identity.ulake_container_identity,
    azurerm_container_app.log_service
  ]
}
