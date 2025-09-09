resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location_display_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.cluster_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.64.0/18"]

  service_endpoints = [
    "Microsoft.Storage"
  ]
}

