variable "server_name" {
  type        = string
  description = "Name of the PostgreSQL Flexible Server"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "vnet_id" {
  type        = string
  description = "Virtual Network ID for Private DNS Zone Link"
}

variable "db_subnet_id" {
  type        = string
  description = "Subnet ID delegated to Flexible Server"
}

variable "admin_user" {
  type        = string
  description = "PostgreSQL administrator username."
  default     = "pgadmin"
}

variable "admin_password" {
  type        = string
  description = "PostgreSQL administrator password."
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Application database name."
  default     = "uit_dkhp"
}

variable "postgresql_version" {
  type        = string
  description = "PostgreSQL Flexible Server version."
  default     = "16"
}

variable "storage_mb" {
  type        = number
  description = "PostgreSQL storage in MB."
  default     = 32768
}

variable "sku_name" {
  type        = string
  description = "PostgreSQL Flexible Server SKU."
  default     = "B_Standard_B1ms"
}

variable "zone" {
  type        = string
  description = "PostgreSQL availability zone."
  default     = "1"
}

variable "backup_retention_days" {
  type        = number
  description = "PostgreSQL backup retention in days."
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backup."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to database resources."
  default     = {}
}
