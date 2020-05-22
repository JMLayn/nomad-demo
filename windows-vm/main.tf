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
  name                = "rjackson-windows-0.05"
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
  custom_data = "JE1ldGFEYXRhSGVhZGVycyA9IEB7Ik1ldGFkYXRhIj0idHJ1ZSJ9IApJbnZva2UtUmVzdE1ldGhvZCAtTWV0aG9kIEdFVCAtdXJpICJodHRwOi8vMTY5LjI1NC4xNjkuMjU0L21ldGFkYXRhL2luc3RhbmNlL25ldHdvcmsvaW50ZXJmYWNlLzAvaXB2NC9pcGFkZHJlc3MvMC9wdWJsaWNpcD9hcGktdmVyc2lvbj0yMDE3LTAzLTAxJmZvcm1hdD10ZXh0IiAtSGVhZGVycyAkTWV0YURhdGFIZWFkZXJzIAoKTmV3LUl0ZW0gJ0M6XGhhc2hpY29ycFxub21hZC5kXG5vbWFkLWNsaWVudC5oY2wnClNldC1Db250ZW50ICdDOlxoYXNoaWNvcnBcbm9tYWQuZFxub21hZC1jbGllbnQuaGNsJyAnYWR2ZXJ0aXNlIHsnIApTZXQtQ29udGVudCAnQzpcaGFzaGljb3JwXG5vbWFkLmRcbm9tYWQtY2xpZW50LmhjbCcgJyAgIGh0dHA9IiRjbGllbnRfcHVibGljX0lQIicKU2V0LUNvbnRlbnQgJ0M6XGhhc2hpY29ycFxub21hZC5kXG5vbWFkLWNsaWVudC5oY2wnICcgICBycGM9IiRjbGllbnRfcHVibGljX0lQIicKU2V0LUNvbnRlbnQgJ0M6XGhhc2hpY29ycFxub21hZC5kXG5vbWFkLWNsaWVudC5oY2wnICcgICBzZXJmPSIkY2xpZW50X3B1YmxpY19JUCInClNldC1Db250ZW50ICdDOlxoYXNoaWNvcnBcbm9tYWQuZFxub21hZC1jbGllbnQuaGNsJyAnYWR2ZXJ0aXNlIH0nCg=="
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
  provisioner "file" {
    source = "setupclient.ps1"
    destination = "c:\\hashicorp\\setupclient.ps1"
  }
  provisioner "remote-exec" {
    inline = [
      // "New-Item 'C:/hashicorp/nomad.d/nomad-client.hcl'"
      "powershell -ExecutionPolicy Unrestricted -File  c:\\hashicorp\\setupclient.ps1 -client_public_IP ${azurerm_public_ip.main-ip.ip_address}"
    ]
  }
  // provisioner "remote-exec" {
  //   inline = [
  //     "powershell New-Item 'C:/robwashere.txt'"
  //   ]
  // }
  connection {
    host = azurerm_windows_virtual_machine.example.public_ip_address
    port = "5985"
    type = "winrm"
    user = azurerm_windows_virtual_machine.example.admin_username
    password = azurerm_windows_virtual_machine.example.admin_password
    insecure = false
    https = false
  }
}

output "host_ip" {
  value = azurerm_windows_virtual_machine.example.public_ip_address
}