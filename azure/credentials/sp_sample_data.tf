data "azurerm_storage_account" "sample_data" {
  name                = var.sample_data_storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_container" "sample_data" {
  name                 = var.sample_data_storage_container_name
  storage_account_name = data.azurerm_storage_account.sample_data.name
}

resource "azuread_application" "vectormpp_sample_data" {
  display_name = var.sample_data_reader_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "vectormpp_sample_data" {
  client_id = azuread_application.vectormpp_sample_data.client_id
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_assignment" "sample_data" {
  principal_id   = azuread_service_principal.vectormpp_sample_data.object_id
  role_definition_name = "Storage Blob Data Reader"
  scope          = data.azurerm_storage_container.sample_data.resource_manager_id
}
