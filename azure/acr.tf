resource "azurerm_container_registry" "acr" {
  name                = "ulake"
  resource_group_name = azurerm_resource_group.ulake_rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

  depends_on = [azurerm_resource_group.ulake_rg]
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.ulake_container_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id

  depends_on = [azurerm_container_registry.acr, azurerm_user_assigned_identity.ulake_container_identity]
}

resource "null_resource" "push_images" {
  depends_on = [azurerm_container_registry.acr, azurerm_role_assignment.acr_pull]

  provisioner "local-exec" {
    command = <<EOT
      sleep 5;
      az acr login --name ${azurerm_container_registry.acr.name} ;

      docker push ulake.azurecr.io/ulake-nginx:latest;
      docker push ulake.azurecr.io/ulake-service-log:latest;
      docker push ulake.azurecr.io/ulake-service-user:latest;
      docker push ulake.azurecr.io/ulake-service-acl:latest;
      docker push ulake.azurecr.io/ulake-service-dashboard:latest;
      docker push ulake.azurecr.io/ulake-service-folder:latest;
      docker push ulake.azurecr.io/ulake-service-core:latest
    EOT
  }
}
