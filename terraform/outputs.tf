# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.aks.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.aks.location
}

# AKS Cluster Outputs
output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "cluster_endpoint" {
  description = "The endpoint for the AKS cluster API server"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

# Kubernetes Configuration
output "kube_config" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "client_certificate" {
  description = "The client certificate for cluster authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "The client key for cluster authentication"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_key
  sensitive   = true
}

# Identity and RBAC
output "cluster_identity" {
  description = "The managed identity of the AKS cluster"
  value = {
    type         = azurerm_kubernetes_cluster.aks.identity[0].type
    principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
  }
}

output "kubelet_identity" {
  description = "The kubelet identity of the AKS cluster"
  value = {
    client_id                 = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
    object_id                 = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    user_assigned_identity_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].user_assigned_identity_id
  }
}

# Monitoring
output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.aks.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.aks.name
}

# Node Pool Information
output "default_node_pool" {
  description = "Information about the default node pool"
  value = {
    name       = azurerm_kubernetes_cluster.aks.default_node_pool[0].name
    vm_size    = azurerm_kubernetes_cluster.aks.default_node_pool[0].vm_size
    node_count = azurerm_kubernetes_cluster.aks.default_node_pool[0].node_count
    zones      = azurerm_kubernetes_cluster.aks.default_node_pool[0].zones
  }
}

output "workload_node_pool_id" {
  description = "The ID of the workload node pool (if created)"
  value       = var.create_workload_node_pool ? azurerm_kubernetes_cluster_node_pool.workload[0].id : null
}

# Network Configuration
output "network_profile" {
  description = "The network profile of the AKS cluster"
  value = {
    network_plugin = azurerm_kubernetes_cluster.aks.network_profile[0].network_plugin
    network_policy = azurerm_kubernetes_cluster.aks.network_profile[0].network_policy
    dns_service_ip = azurerm_kubernetes_cluster.aks.network_profile[0].dns_service_ip
    service_cidr   = azurerm_kubernetes_cluster.aks.network_profile[0].service_cidr
    pod_cidr       = azurerm_kubernetes_cluster.aks.network_profile[0].pod_cidr
  }
}

# Connection Commands
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "cluster_info" {
  description = "Summary of cluster information"
  value = {
    cluster_name      = azurerm_kubernetes_cluster.aks.name
    resource_group    = azurerm_resource_group.aks.name
    location          = azurerm_resource_group.aks.location
    kubernetes_version = azurerm_kubernetes_cluster.aks.kubernetes_version
    node_count        = azurerm_kubernetes_cluster.aks.default_node_pool[0].node_count
    vm_size           = azurerm_kubernetes_cluster.aks.default_node_pool[0].vm_size
  }
}