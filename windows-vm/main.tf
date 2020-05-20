provider "azurerm" {
  features {}
  version = ">=2.0.0"
}

variable "prefix" {
  default = "rj-win"
}

// Data Sources - should be pulled from variables used for Packer image deployment
data "azurerm_resource_group" "main-rg" {
  name = "rjackson-rg"
}

data "azurerm_image" "search" {
  name                = "rjackson-windows-0.03"
  resource_group_name = data.azurerm_resource_group.main-rg.name
}

// Supporting resources.
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.main-rg.location
  resource_group_name = data.azurerm_resource_group.main-rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main-rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main-ip" {
  name                = "main-public_ip"
  location            = data.azurerm_resource_group.main-rg.location
  resource_group_name = data.azurerm_resource_group.main-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.main-rg.location
  resource_group_name = data.azurerm_resource_group.main-rg.name

  ip_configuration {
    name                          = "${var.prefix}-private_ip"
    subnet_id                     = azurerm_subnet.internal.id
    public_ip_address_id          = azurerm_public_ip.main-ip.id
    private_ip_address_allocation = "Dynamic"
  }
}



resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.prefix}-Machine"
  resource_group_name = data.azurerm_resource_group.main-rg.name
  location            = data.azurerm_resource_group.main-rg.location
  size                = "Standard_F2"
  source_image_id     = data.azurerm_image.search.id
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  winrm_listener {
    protocol = "Http"
  }

  os_disk {
    name                 = "${var.prefix}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource null_resource "winrm_provisioner" {
  // provisioner "file" {
  //   source = "setupclient.ps1"
  //   destination = "c:\\hashicorp\\setupclient.ps1"
  // }
  provisioner "remote-exec" {
    inline = [
      "New-Item 'C:/hashicorp/nomad.d/nomad-client.hcl'"
      // "powershell -ExecutionPolicy Unrestricted -File  c:\\hashicorp\\setupclient.ps1 -client_public_IP ${azurerm_public_ip.main-ip.ip_address}"
    ]
  }
  connection {
    host = azurerm_windows_virtual_machine.example.public_ip_address
    port = "5985"
    type = "winrm"
    user = azurerm_windows_virtual_machine.example.admin_username
    password = azurerm_windows_virtual_machine.example.admin_password
    insecure = true
    https = false
  }
}