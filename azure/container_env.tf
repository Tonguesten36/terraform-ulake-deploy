resource "azurerm_container_app_environment" "env" {
  name                = "ulake-env"
  location            = var.location
  resource_group_name = azurerm_resource_group.ulake_rg.name

  infrastructure_subnet_id = azurerm_subnet.containerapps_subnet.id

  depends_on = [azurerm_subnet.containerapps_subnet, azurerm_virtual_network.ulake_vnet]
}
