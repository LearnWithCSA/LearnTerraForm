resource "azurerm_resource_group" "emreg-terraformtestrg" {
  name     = "emreg-terraformtest"
  location = "West Europe"
}

resource "azurerm_storage_account" "emreg-terraformtestsa" {
  name                     = "emreg-terraformtestsa"
  resource_group_name      = azurerm_resource_group.emreg-terraformtestrg.name
  location                 = azurerm_resource_group.emreg-terraformtestrg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}