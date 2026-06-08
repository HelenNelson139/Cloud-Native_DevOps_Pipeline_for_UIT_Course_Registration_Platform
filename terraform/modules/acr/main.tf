resource "azurerm_container_registry" "acr" {
  #checkov:skip=CKV_AZURE_139:Public ACR endpoint is kept for a low-cost AKS lab; production should use Premium ACR with Private Link.
  #checkov:skip=CKV_AZURE_163:Image vulnerability scanning is handled by Trivy in GitHub Actions for this project.
  #checkov:skip=CKV_AZURE_164:Trusted image signing is outside the course lab scope; Trivy and immutable SHA tags are used instead.
  #checkov:skip=CKV_AZURE_165:Geo-replication requires Premium ACR and is not required for this single-region lab.
  #checkov:skip=CKV_AZURE_166:ACR quarantine/verification is outside lab scope; CI performs image scanning before push.
  #checkov:skip=CKV_AZURE_167:ACR retention policy requires Premium SKU; lab uses Basic SKU for cost control.
  #checkov:skip=CKV_AZURE_233:ACR zone redundancy requires Premium SKU; lab uses Basic SKU for cost control.
  #checkov:skip=CKV_AZURE_237:Dedicated data endpoints require Premium SKU; lab uses Basic SKU for cost control.
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false
  tags                = var.tags
}
