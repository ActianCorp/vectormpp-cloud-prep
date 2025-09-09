data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "azurerm_resource_group" "vectormpp" {
  name = var.resource_group_name
}

