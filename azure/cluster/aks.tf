resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location_display_name
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  default_node_pool {
    name       = "default"
    node_count = var.min_node_count
    min_count  = var.min_node_count
    max_count  = var.max_node_count
    vm_size    = var.node_type
    auto_scaling_enabled = true
    os_disk_size_gb = 200
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  kubernetes_version = var.cluster_version

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    service_cidr        = "10.1.0.0/16"
    dns_service_ip      = "10.1.0.10"
    pod_cidr            = "10.2.0.0/16"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count,
    ]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    BelongTo = "VectorMPP"
  }
}

data "azurerm_user_assigned_identity" "user_assigned_id" {
  name                = var.user_assigned_managed_identity_name
  resource_group_name = var.resource_group_name
}

# subject must not be changed, vectormpp-dataplane:agent is hardcoded in VectorMPP code.
resource "azurerm_federated_identity_credential" "fedrrated_id_cred" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = data.azurerm_user_assigned_identity.user_assigned_id.id
  subject             = "system:serviceaccount:vectormpp-dataplane:agent"
}

