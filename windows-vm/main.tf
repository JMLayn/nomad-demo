provider "azurerm" {
  features {}
  version  = ">=2.0.0"
}

data "azurerm_image" "rj-image" {
  name                = "rjackson-windows-0.01"
  resource_group_name = "rjackson-rg"
}

output "image_id" {
  value = data.azurerm_image.rj-image.id
}

module mycompute {
    source = "Azure/compute/azurerm"
    resource_group_name = "rjackson-rg"
    admin_password = "ComplxP@assw0rd!"
    vm_os_id = data.azurerm_image.rj-image.id
    is_windows_image = "true"
    remote_port = "3389"
    nb_instances = 1
    public_ip_dns = ["rj-domain"]
    vnet_subnet_id = module.network.vnet_subnets[0]
}

module "network" {
    source = "Azure/network/azurerm"
    resource_group_name = "rjackson-rg"
}

output "vm_public_name" {
    value = module.mycompute.public_ip_dns_name
}

output "vm_public_ip" {
    value = module.mycompute.public_ip_address
}

output "vm_private_ips" {
    value = module.mycompute.network_interface_private_ip
}
