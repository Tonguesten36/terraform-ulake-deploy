resource "azurerm_resource_group" "ulake_rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "ulake_vnet" {
  name                = "ulake-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.ulake_rg.name
  address_space       = ["10.0.0.0/16"]

  depends_on = [azurerm_resource_group.ulake_rg]
}
resource "azurerm_subnet" "containerapps_subnet" {
  name                 = "containerapps-subnet"
  resource_group_name  = azurerm_resource_group.ulake_rg.name
  virtual_network_name = azurerm_virtual_network.ulake_vnet.name
  address_prefixes     = ["10.0.0.0/23"] # /23 is the minimum CIDR block size for Container App Environment

  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]

  depends_on = [azurerm_virtual_network.ulake_vnet]
}
resource "azurerm_subnet" "mysql_subnet" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.ulake_rg.name
  virtual_network_name = azurerm_virtual_network.ulake_vnet.name
  address_prefixes     = ["10.0.2.0/23"] # all addresses in the block size of /23 must be even numbers

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }

  depends_on = [azurerm_virtual_network.ulake_vnet]
}

resource "azurerm_user_assigned_identity" "ulake_container_identity" {
  location            = azurerm_resource_group.ulake_rg.location
  name                = "ulake-container-identity"
  resource_group_name = azurerm_resource_group.ulake_rg.name
}
