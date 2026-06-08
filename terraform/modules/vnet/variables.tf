variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
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

variable "tags" {
  type        = map(string)
  description = "Tags applied to taggable network resources."
  default     = {}
}
