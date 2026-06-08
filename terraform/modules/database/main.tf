resource "azurerm_private_dns_zone" "default" {
  name                = "${var.server_name}-pdz.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${var.server_name}-pdz-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  #checkov:skip=CKV_AZURE_136:Geo-redundant backup is configurable but disabled by default for low-cost lab environments.
  #checkov:skip=CKV2_AZURE_57:Flexible Server is deployed into a delegated private subnet with public access disabled instead of a separate Private Endpoint.
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgresql_version
  delegated_subnet_id           = var.db_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.default.id
  public_network_access_enabled = false
  administrator_login           = var.admin_user
  administrator_password        = var.admin_password
  zone                          = var.zone
  storage_mb                    = var.storage_mb
  sku_name                      = var.sku_name
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  tags                          = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
