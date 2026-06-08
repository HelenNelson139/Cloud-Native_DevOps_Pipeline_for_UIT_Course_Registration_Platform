variable "project_name" {
  type        = string
  description = "Project name used for common tags."
  default     = "uit-course-registration"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name."
  default     = "uit-dkhp-rg"
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "Southeast Asia"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to Azure resources."
  default     = {}
}

variable "acr_name" {
  type        = string
  description = "Globally unique Azure Container Registry name."
  default     = "uitdkhpacr2026"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must be 5-50 alphanumeric characters."
  }
}

variable "acr_sku" {
  type        = string
  description = "Azure Container Registry SKU."
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

variable "vnet_name" {
  type        = string
  description = "Virtual network name."
  default     = "devops-vnet"
}

variable "vnet_address_space" {
  type        = string
  description = "Virtual network CIDR."
  default     = "10.0.0.0/16"
}

variable "aks_subnet_name" {
  type        = string
  description = "AKS subnet name."
  default     = "aks-subnet"
}

variable "aks_subnet_prefix" {
  type        = string
  description = "AKS subnet CIDR."
  default     = "10.0.1.0/24"
}

variable "db_subnet_name" {
  type        = string
  description = "Database subnet name."
  default     = "db-subnet"
}

variable "db_subnet_prefix" {
  type        = string
  description = "Database subnet CIDR."
  default     = "10.0.2.0/24"
}

variable "aks_cluster_name" {
  type        = string
  description = "AKS cluster name."
  default     = "devops-aks"
}

variable "aks_dns_prefix" {
  type        = string
  description = "AKS DNS prefix."
  default     = "devopsaks"
}

variable "aks_node_count" {
  type        = number
  description = "Initial AKS node count."
  default     = 1
}

variable "aks_min_count" {
  type        = number
  description = "Minimum autoscaling node count."
  default     = 1
}

variable "aks_max_count" {
  type        = number
  description = "Maximum autoscaling node count."
  default     = 3
}

variable "aks_vm_size" {
  type        = string
  description = "AKS default node pool VM size."
  default     = "Standard_B2s_v2"
}

variable "aks_service_cidr" {
  type        = string
  description = "AKS service CIDR."
  default     = "10.1.0.0/16"
}

variable "aks_dns_service_ip" {
  type        = string
  description = "AKS DNS service IP."
  default     = "10.1.0.10"
}

variable "aks_node_pool_name" {
  type        = string
  description = "AKS default node pool name."
  default     = "default"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,11}$", var.aks_node_pool_name))
    error_message = "aks_node_pool_name must start with a lowercase letter and contain at most 12 lowercase alphanumeric characters."
  }
}

variable "aks_upgrade_max_surge" {
  type        = string
  description = "AKS node pool upgrade max surge."
  default     = "10%"
}

variable "aks_max_pods" {
  type        = number
  description = "Maximum pods per AKS node."
  default     = 50
}

variable "aks_automatic_channel_upgrade" {
  type        = string
  description = "AKS automatic upgrade channel."
  default     = "patch"

  validation {
    condition     = contains(["patch", "stable", "rapid", "node-image"], var.aks_automatic_channel_upgrade)
    error_message = "aks_automatic_channel_upgrade must be patch, stable, rapid, or node-image."
  }
}

variable "enable_monitoring" {
  type        = bool
  description = "Install kube-prometheus-stack with Helm."
  default     = true
}

variable "db_server_name" {
  type        = string
  description = "PostgreSQL Flexible Server name."
  default     = "uit-dkhp-pg-server"
}

variable "db_admin_user" {
  type        = string
  description = "PostgreSQL administrator username."
  default     = "pgadmin"
}

variable "db_admin_password" {
  type        = string
  description = "PostgreSQL administrator password."
  sensitive   = true

  validation {
    condition     = length(var.db_admin_password) >= 12
    error_message = "db_admin_password must be at least 12 characters."
  }
}

variable "db_name" {
  type        = string
  description = "Application database name."
  default     = "uit_dkhp"
}

variable "db_postgresql_version" {
  type        = string
  description = "PostgreSQL Flexible Server version."
  default     = "16"
}

variable "db_storage_mb" {
  type        = number
  description = "PostgreSQL storage in MB."
  default     = 32768
}

variable "db_sku_name" {
  type        = string
  description = "PostgreSQL Flexible Server SKU."
  default     = "B_Standard_B1ms"
}

variable "db_zone" {
  type        = string
  description = "PostgreSQL availability zone."
  default     = "1"
}

variable "db_backup_retention_days" {
  type        = number
  description = "PostgreSQL backup retention in days."
  default     = 7

  validation {
    condition     = var.db_backup_retention_days >= 7 && var.db_backup_retention_days <= 35
    error_message = "db_backup_retention_days must be between 7 and 35."
  }
}

variable "db_geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant PostgreSQL backups. Use false for low-cost lab environments."
  default     = false
}

variable "monitoring_chart_version" {
  type        = string
  description = "kube-prometheus-stack Helm chart version."
  default     = "85.2.2"
}
