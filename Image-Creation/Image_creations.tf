# Setting up the resource group and storage account for the image
provider "azurerm" {
  features {}
  version  = ">=2.0.0"
}

resource "azurerm_resource_group" "nomad" {
  name     = var.nomad_rg
  location = var.azure_location
  tags = {
    Owner = var.owner
  }
}

resource "azurerm_storage_account" "nomad" {
  name                     = "${var.nomad_storage}${var.azure_location}"
  resource_group_name      = azurerm_resource_group.nomad.name
  location                 = azurerm_resource_group.nomad.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    Owner = var.owner
  }
}

# Packer Runners to build images - separating teh resources to enable individual resource taints
resource "null_resource" "azure_packer_runner" {
  depends_on = [
    azurerm_storage_account.nomad,azurerm_resource_group.nomad
  ]
  provisioner "local-exec" {
    command     = "packer build -var owner=${var.owner} -var resource_group_name=${var.nomad_rg} -var storage_account=${var.nomad_storage} -var location=${var.azure_location} Azure_Windows_image.json"
  }
}

resource "null_resource" "aws_packer_runner" {
  depends_on = [
    azurerm_storage_account.nomad,azurerm_resource_group.nomad
  ]
  provisioner "local-exec" {
    command     = "packer build -var owner=${var.owner} -var aws_region=${var.aws_region} -var aws_instance_type=${var.aws_instance_type} AWS_linux_image.pkr.hcl"
  }
}

output "Azure_Resource_Group" {
  value = var.nomad_rg
}
output "Azure_Location" {
  value = var.azure_location
}
output "Azure_Image_Name" {
  value = var.azure_location
}
output "AWS_Region" {
  value = var.aws_region
}
output "AWS_Image_Name" {
  value = var.azure_location
}