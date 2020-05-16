provider "azurerm" {
  features {}
  version  = ">=2.0.0"
}

resource "azurerm_resource_group" "rjackson" {
  name     = "rjackson-rg"
  location = "eastus2"
}

resource "azurerm_storage_account" "rjacksonstorage" {
  name                     = "rjacksonstorage"
  resource_group_name      = azurerm_resource_group.rjackson.name
  location                 = azurerm_resource_group.rjackson.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Owner = "rjackson"
  }
}