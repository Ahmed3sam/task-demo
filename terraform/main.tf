# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = "rg"
}

# Generate random suffix for ACR name (must be globally unique)
resource "random_string" "acr_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create Resource Group
resource "azurerm_resource_group" "aks" {
  name     = random_pet.rg_name.id
  location = var.location

  tags = var.tags
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Default node pool
  default_node_pool {
    name            = "default"
    node_count      = var.auto_scaling_enabled ? null : var.node_count
    vm_size         = var.vm_size
    type            = "VirtualMachineScaleSets"
    enable_auto_scaling = var.auto_scaling_enabled
    min_count       = var.auto_scaling_enabled ? var.min_count : null
    max_count       = var.auto_scaling_enabled ? var.max_count : null
    
    # Enable zones for high availability
    zones = var.availability_zones
    
    # OS and storage settings
    os_disk_size_gb = var.os_disk_size_gb
    os_disk_type    = "Managed"
    
    # Network settings
    vnet_subnet_id = var.subnet_id
    
    # Node labels and taints
    node_labels = var.node_labels
    
    tags = var.tags
  }

  # Identity configuration
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    pod_cidr          = var.network_plugin == "kubenet" ? var.pod_cidr : null
    outbound_type     = var.outbound_type
  }

  # RBAC and Azure AD integration
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  # Security and monitoring
  role_based_access_control_enabled = true
  local_account_disabled            = var.local_account_disabled
  
  # Enable monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  # Enable Azure Policy
  azure_policy_enabled = var.azure_policy_enabled

  # Enable Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Maintenance window
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }

  maintenance_window_node_os {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }

  tags = var.tags
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# Note: ACR configuration removed for now to focus on AKS deployment

# Create additional node pool for workloads
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  count                 = var.create_workload_node_pool ? 1 : 0
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.workload_vm_size
  node_count            = var.workload_node_count
  enable_auto_scaling   = var.workload_auto_scaling_enabled
  min_count             = var.workload_auto_scaling_enabled ? var.workload_min_count : null
  max_count             = var.workload_auto_scaling_enabled ? var.workload_max_count : null
  
  zones = var.availability_zones
  
  os_disk_size_gb = var.workload_os_disk_size_gb
  os_disk_type    = "Managed"
  
  vnet_subnet_id = var.subnet_id
  
  node_labels = var.workload_node_labels
  node_taints = var.workload_node_taints

  tags = var.tags
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.cluster_name, "-", "")}acrdemo"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = var.acr_sku
  admin_enabled       = false

  # Security settings for private cluster
  public_network_access_enabled = var.acr_public_network_access_enabled
  
  # Enable zone redundancy for Premium SKU
  zone_redundancy_enabled = var.acr_sku == "Premium" ? var.acr_zone_redundancy_enabled : false

  # Network rules for Premium SKU
  dynamic "network_rule_set" {
    for_each = var.acr_sku == "Premium" && var.acr_network_rule_set != null ? [var.acr_network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  tags = var.tags
}

# Role assignment to allow AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_container_registry.main
  ]
}