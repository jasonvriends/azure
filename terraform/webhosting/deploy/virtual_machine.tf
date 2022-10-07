# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine

resource "azurerm_linux_virtual_machine" "vm_webhosting" {
  name                = "${var.suffix}-vm"
  resource_group_name = azurerm_resource_group.rg_compute.name
  location            = azurerm_resource_group.rg_compute.location
  size                = "${var.vm_size}"
  admin_username      = "${var.vm_admin_username}"
  network_interface_ids = [
    azurerm_network_interface.nic_webhosting.id,
  ]

  admin_ssh_key {
    username   = "${var.vm_admin_username}"
    public_key = file("${var.vm_public_key}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "128"
    name                 = "${var.suffix}-osdisk"
  }

  source_image_reference {
    publisher = "litespeedtechnologies"
    offer     = "cyberpanel"
    sku       = "cyberpanel"
    version   = "latest"
  }

  plan {
    name          = "cyberpanel"
    publisher     = "litespeedtechnologies"
    product       = "cyberpanel"
  }

}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "nic_webhosting" {
  name                = "${var.suffix}-nic"
  location            = azurerm_resource_group.rg_compute.location
  resource_group_name = azurerm_resource_group.rg_compute.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet_subnet_webhosting_public.id

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip_webhosting.id

  }

}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "pip_webhosting" {
  name                = "${var.suffix}-pip"
  resource_group_name = azurerm_resource_group.rg_network.name
  location            = azurerm_resource_group.rg_network.location
  allocation_method   = "Static"
}