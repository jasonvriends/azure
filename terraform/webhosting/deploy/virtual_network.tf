# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "vnet_webhosting" {
  name                = "${var.suffix}-vnet"
  location            = azurerm_resource_group.rg_network.location
  resource_group_name = azurerm_resource_group.rg_network.name
  address_space       = ["10.0.0.0/16"]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "vnet_subnet_webhosting_public" {
  name                 = "public"
  resource_group_name  = azurerm_resource_group.rg_network.name
  virtual_network_name = azurerm_virtual_network.vnet_webhosting.name
  address_prefixes     = ["10.0.1.0/24"]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association

resource "azurerm_subnet_network_security_group_association" "vnet_nsg_association_public" {
  subnet_id                 = azurerm_subnet.vnet_subnet_webhosting_public.id
  network_security_group_id = azurerm_network_security_group.nsg_webhosting.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "nsg_webhosting" {
  name                = "${var.suffix}-nsg"
  location            = azurerm_resource_group.rg_network.location
  resource_group_name = azurerm_resource_group.rg_network.name

  security_rule {
    name                       = "dns"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "http"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

   security_rule {
    name                       = "ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.remoteaccess}"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "panel"
    priority                   = 125
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8090"
    source_address_prefix      = "${var.remoteaccess}"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "webadmin"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7080"
    source_address_prefix      = "${var.remoteaccess}"
    destination_address_prefix = "*"
  }  

}