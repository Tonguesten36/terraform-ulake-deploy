# Storage account for mounting volumes to containers
resource "azurerm_storage_account" "ulake_store" {
  name                     = "ulakestore"
  resource_group_name      = azurerm_resource_group.ulake_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  public_network_access_enabled = true

  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [ azurerm_subnet.containerapps_subnet ]
  }

  depends_on = [azurerm_resource_group.ulake_rg]
}
resource "azurerm_storage_share" "ulake_runner_fileshare" {
  name               = "ulake-runner"
  storage_account_id = azurerm_storage_account.ulake_store.id
  quota              = 2 # in GB
  access_tier = "Hot"

  depends_on = [azurerm_storage_account.ulake_store]
}
resource "azurerm_storage_share" "nginx_conf_fileshare" {
  name               = "ulake-nginx-conf"
  storage_account_id = azurerm_storage_account.ulake_store.id
  quota              = 1 # in GB
  access_tier = "Hot"

  depends_on = [azurerm_storage_account.ulake_store]
}
resource "azurerm_storage_share" "nginx_html_fileshare" {
  name               = "ulake-nginx-html"
  storage_account_id = azurerm_storage_account.ulake_store.id
  quota              = 1 # in GB
  access_tier = "Hot"

  depends_on = [azurerm_storage_account.ulake_store]
}

# Making sure that the microservices can access the runner executables
resource "azurerm_user_assigned_identity" "ulake_container_identity" {
  name                = "ulake-container-identity"
  resource_group_name = azurerm_resource_group.ulake_rg.name
  location            = var.location

  depends_on = [azurerm_resource_group.ulake_rg]
}
resource "azurerm_role_assignment" "ulake_storage_access" {
  principal_id         = azurerm_user_assigned_identity.ulake_container_identity.principal_id
  role_definition_name = "Storage File Data SMB Share Reader"
  scope                = azurerm_storage_account.ulake_store.id

  depends_on = [azurerm_storage_account.ulake_store, azurerm_user_assigned_identity.ulake_container_identity]
}
