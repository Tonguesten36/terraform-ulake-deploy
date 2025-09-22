resource "azurerm_container_app" "nginx_service" {
  name                         = "ulake-nginx"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.ulake_rg.name
  revision_mode                = "Single"

  template {
    container {
      name  = "nginx"
      image = "${azurerm_container_registry.acr.login_server}/nginx-proxy:latest"

      cpu    = "0.5"
      memory = "1Gi"

      volume_mounts {
        name = "html"
        path = "/opt/ulake-nginx"
      }

      volume_mounts {
        name = "conf"
        path = "/etc/nginx"
      }
    }

    volume {
      name          = "html"
      storage_name  = azurerm_storage_account.ulake_store.name
      storage_type  = "AzureFile"
      mount_options = "dir_mode=0755,file_mode=0755"
    }

    volume {
      name          = "conf"
      storage_name  = azurerm_storage_account.ulake_store.name
      storage_type  = "AzureFile"
      mount_options = "dir_mode=0755,file_mode=0644"
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport = "http"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ulake_container_identity.id]
  }

  depends_on = [
    azurerm_container_app_environment.env,
    azurerm_storage_account.ulake_store,
    null_resource.push_nginx_image,
    null_resource.upload_nginx_conf,
    null_resource.upload_nginx_html
  ]
}
