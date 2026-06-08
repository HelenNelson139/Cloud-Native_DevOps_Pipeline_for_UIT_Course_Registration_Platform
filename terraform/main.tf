locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "Cloud-Native_DevOps_Pipeline_for_UIT_Course_Registration_Platform"
    },
    var.tags
  )
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_name     = var.aks_subnet_name
  aks_subnet_prefix   = var.aks_subnet_prefix
  db_subnet_name      = var.db_subnet_name
  db_subnet_prefix    = var.db_subnet_prefix
  tags                = local.common_tags
}

module "aks" {
  source                    = "./modules/aks"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  vnet_subnet_id            = module.vnet.aks_subnet_id
  cluster_name              = var.aks_cluster_name
  dns_prefix                = var.aks_dns_prefix
  node_pool_name            = var.aks_node_pool_name
  node_count                = var.aks_node_count
  min_count                 = var.aks_min_count
  max_count                 = var.aks_max_count
  vm_size                   = var.aks_vm_size
  service_cidr              = var.aks_service_cidr
  dns_service_ip            = var.aks_dns_service_ip
  upgrade_max_surge         = var.aks_upgrade_max_surge
  max_pods                  = var.aks_max_pods
  automatic_channel_upgrade = var.aks_automatic_channel_upgrade
  tags                      = local.common_tags

  depends_on = [module.vnet]
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  acr_name            = var.acr_name
  sku                 = var.acr_sku
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = module.aks.kubelet_identity_object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.acr_id
  skip_service_principal_aad_check = true
}

module "database" {
  source                       = "./modules/database"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  server_name                  = var.db_server_name
  vnet_id                      = module.vnet.vnet_id
  db_subnet_id                 = module.vnet.db_subnet_id
  admin_user                   = var.db_admin_user
  admin_password               = var.db_admin_password
  db_name                      = var.db_name
  postgresql_version           = var.db_postgresql_version
  storage_mb                   = var.db_storage_mb
  sku_name                     = var.db_sku_name
  zone                         = var.db_zone
  backup_retention_days        = var.db_backup_retention_days
  geo_redundant_backup_enabled = var.db_geo_redundant_backup_enabled
  tags                         = local.common_tags

  depends_on = [module.vnet]
}

module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./modules/monitoring"

  values_file = "${path.module}/../monitoring/helm/kube-prometheus-stack-values.yaml"
  extra_values_files = [
    "${path.module}/../monitoring/helm/alertmanager-teams-values.yaml"
  ]
  chart_version = var.monitoring_chart_version

  depends_on = [module.aks]
}
