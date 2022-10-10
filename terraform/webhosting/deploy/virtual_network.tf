# https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http

data "http" "clientip" {
  url = "https://ipv4.icanhazip.com/"
}

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
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "http"
    priority                   = 101
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
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "ftp"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["21","40110-40210"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "mail"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["25","587","465","110","143","993"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  


   security_rule {
    name                       = "ssh"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.remoteaccess == "" ? chomp(data.http.clientip.response_body) : var.remoteaccess
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "cyberpanel"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8090"
    source_address_prefix      = var.remoteaccess == "" ? chomp(data.http.clientip.response_body) : var.remoteaccess
    destination_address_prefix = "*"
  }  

}