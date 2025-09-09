resource "azurerm_user_assigned_identity" "user_assigned_id" {
  name                = var.user_assigned_id_name
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.vectormpp.location
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  principal_id         = azurerm_user_assigned_identity.user_assigned_id.principal_id
  role_definition_name = "Storage Account Contributor"
  scope                = data.azurerm_resource_group.vectormpp.id
}

resource "azurerm_role_assignment" "vnet_reader" {
  principal_id         = azurerm_user_assigned_identity.user_assigned_id.principal_id
  role_definition_name = "Reader"
  scope                = data.azurerm_resource_group.vectormpp.id
}
