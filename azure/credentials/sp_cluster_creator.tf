resource "azuread_application" "cluster_creator" {
  display_name = var.cluster_creator_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "cluster_creator" {
  client_id = azuread_application.cluster_creator.client_id
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "sp_reader" {
  principal_id         = azuread_service_principal.cluster_creator.object_id
  role_definition_name = "Reader"
  scope                = data.azurerm_subscription.current.id
}

resource "azurerm_role_assignment" "contributor" {
  principal_id         = azuread_service_principal.cluster_creator.object_id
  role_definition_name = "Contributor"
  scope                = data.azurerm_resource_group.vectormpp.id
}

resource "azurerm_role_assignment" "vnet" {
  principal_id         = azuread_service_principal.cluster_creator.object_id
  role_definition_name = "Network Contributor"
  scope                = data.azurerm_resource_group.vectormpp.id
}

