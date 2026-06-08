resource "azurerm_kubernetes_cluster" "aks" {
  #checkov:skip=CKV_AZURE_4:Prometheus/Grafana monitoring is managed by the monitoring module; Azure Monitor is not used in this lab.
  #checkov:skip=CKV_AZURE_6:API server authorized IP ranges are intentionally not fixed because lab runner IPs change.
  #checkov:skip=CKV_AZURE_115:Private AKS API endpoint is a production hardening option; public endpoint is kept for course demos.
  #checkov:skip=CKV_AZURE_117:Customer-managed disk encryption set is outside the low-cost lab scope.
  #checkov:skip=CKV_AZURE_141:Local admin remains enabled so Terraform Helm provider can bootstrap monitoring from kubeconfig.
  #checkov:skip=CKV_AZURE_170:Paid AKS SLA is not enabled for the low-cost course lab.
  #checkov:skip=CKV_AZURE_172:Secrets Store CSI rotation is not enabled because the app uses Kubernetes Secrets in this lab.
  #checkov:skip=CKV_AZURE_226:Ephemeral OS disks depend on VM size/cache support and are not enforced for the lab node pool.
  #checkov:skip=CKV_AZURE_227:Host encryption depends on VM support and is not enforced for the lab node pool.
  #checkov:skip=CKV_AZURE_232:System and user node pools are not split in this small lab cluster.
  name                              = var.cluster_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true
  azure_policy_enabled              = true
  local_account_disabled            = false
  automatic_channel_upgrade         = var.automatic_channel_upgrade

  default_node_pool {
    name                = var.node_pool_name
    node_count          = var.node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    max_pods            = var.max_pods

    upgrade_settings {
      max_surge = var.upgrade_max_surge
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}
