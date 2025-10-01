# Resource Group and Location
variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "aks-cluster"
    ManagedBy   = "terraform"
  }
}

# AKS Cluster Configuration
variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use for the AKS cluster"
  type        = string
  default     = null # Uses latest recommended version
}

# Default Node Pool Configuration
variable "node_count" {
  description = "The initial number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the Virtual Machine for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "auto_scaling_enabled" {
  description = "Enable auto-scaling for the default node pool"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum number of nodes in the default node pool when auto-scaling is enabled"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes in the default node pool when auto-scaling is enabled"
  type        = number
  default     = 5
}

variable "availability_zones" {
  description = "List of availability zones for the node pools"
  type        = list(string)
  default     = ["2"]
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB for the default node pool"
  type        = number
  default     = 30
}

variable "node_labels" {
  description = "A map of Kubernetes labels to apply to the default node pool"
  type        = map(string)
  default     = {}
}

# Network Configuration
variable "subnet_id" {
  description = "The ID of the subnet where the AKS cluster will be deployed"
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "Network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy to use for networking (azure, calico, or cilium)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico", "cilium"], var.network_policy)
    error_message = "Network policy must be 'azure', 'calico', or 'cilium'."
  }
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range for cluster service discovery"
  type        = string
  default     = "10.0.0.10"
}

variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pod_cidr" {
  description = "The CIDR to use for pod IP addresses (only used with kubenet)"
  type        = string
  default     = "10.244.0.0/16"
}

variable "outbound_type" {
  description = "The outbound (egress) routing method"
  type        = string
  default     = "loadBalancer"

  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting", "managedNATGateway", "userAssignedNATGateway"], var.outbound_type)
    error_message = "Outbound type must be one of: loadBalancer, userDefinedRouting, managedNATGateway, userAssignedNATGateway."
  }
}

# Security and RBAC Configuration
variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs that will have admin access to the cluster"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

variable "local_account_disabled" {
  description = "Disable local accounts for the cluster"
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy Add-On"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics workspace"
  type        = number
  default     = 30
}

# Note: ACR variables removed for now to focus on AKS deployment

# Workload Node Pool Configuration
variable "create_workload_node_pool" {
  description = "Create an additional node pool for workloads"
  type        = bool
  default     = false
}

variable "workload_vm_size" {
  description = "The size of the Virtual Machine for the workload node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "workload_node_count" {
  description = "The initial number of nodes in the workload node pool"
  type        = number
  default     = 2
}

variable "workload_auto_scaling_enabled" {
  description = "Enable auto-scaling for the workload node pool"
  type        = bool
  default     = true
}

variable "workload_min_count" {
  description = "Minimum number of nodes in the workload node pool when auto-scaling is enabled"
  type        = number
  default     = 1
}

variable "workload_max_count" {
  description = "Maximum number of nodes in the workload node pool when auto-scaling is enabled"
  type        = number
  default     = 10
}

variable "workload_os_disk_size_gb" {
  description = "The size of the OS disk in GB for the workload node pool"
  type        = number
  default     = 50
}

variable "workload_node_labels" {
  description = "A map of Kubernetes labels to apply to the workload node pool"
  type        = map(string)
  default = {
    "workload" = "true"
  }
}

variable "workload_node_taints" {
  description = "A list of Kubernetes taints to apply to the workload node pool"
  type        = list(string)
  default     = []
}

# Azure Container Registry Configuration
variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_public_network_access_enabled" {
  description = "Whether public network access is allowed for ACR"
  type        = bool
  default     = true # Private by default for security
}

variable "acr_zone_redundancy_enabled" {
  description = "Enable zone redundancy for ACR (Premium SKU only)"
  type        = bool
  default     = false
}

variable "acr_network_rule_set" {
  description = "Network rule set for ACR (Premium SKU only)"
  type = object({
    default_action = string
    ip_rules = list(object({
      action   = string
      ip_range = string
    }))
  })
  default = null
}