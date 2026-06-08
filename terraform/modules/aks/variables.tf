variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name."
  default     = "devops-aks"
}

variable "dns_prefix" {
  type        = string
  description = "AKS DNS prefix."
  default     = "devopsaks"
}

variable "node_pool_name" {
  type        = string
  description = "Default node pool name."
  default     = "default"
}

variable "node_count" {
  type        = number
  description = "Initial node count."
  default     = 1
}

variable "min_count" {
  type        = number
  description = "Minimum autoscaling node count."
  default     = 1
}

variable "max_count" {
  type        = number
  description = "Maximum autoscaling node count."
  default     = 3
}

variable "vm_size" {
  type        = string
  description = "Default node pool VM size."
  default     = "Standard_B2s_v2"
}

variable "vnet_subnet_id" {
  type        = string
  description = "Subnet ID for the AKS default node pool."
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes service CIDR."
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "Kubernetes DNS service IP."
  default     = "10.1.0.10"
}

variable "upgrade_max_surge" {
  type        = string
  description = "Default node pool upgrade max surge."
  default     = "10%"
}

variable "max_pods" {
  type        = number
  description = "Maximum pods per node in the default node pool."
  default     = 50
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "AKS automatic upgrade channel."
  default     = "patch"

  validation {
    condition     = contains(["patch", "stable", "rapid", "node-image"], var.automatic_channel_upgrade)
    error_message = "automatic_channel_upgrade must be patch, stable, rapid, or node-image."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the AKS cluster."
  default     = {}
}
