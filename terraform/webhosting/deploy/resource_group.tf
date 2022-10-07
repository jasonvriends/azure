# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

resource "azurerm_resource_group" "rg_compute" {
  name     = var.rg_vms
  location = var.region
}

resource "azurerm_resource_group" "rg_network" {
  name     = var.rg_network
  location = var.region
}