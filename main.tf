#############################
### AWS Instance Creation ###
#############################

provider "aws" {
  version = "~> 2.5"
  region  = var.aws_region
}

data aws_ami "nomad-demo" {
  most_recent = true

  filter {
    name = "name"
    // values = ["{$var.owner}*"]
    values = ["hashi*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  owners = ["self"] # Canonical
}


# Read Manifests in to pull out image IDs
// data "local_file" "azure-manifest" {
//     filename = "packers/azure-manifest.json"
// }

// data "local_file" "aws-manifest" {
//     filename = "packers/aws-manifest.json"
// }

# Create AWS FQDN
data "aws_route53_zone" "selected" {
  name         = "hashidemos.io."
  private_zone = false
}

resource "aws_route53_record" "fqdn" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.owner}-nomad.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.nomad-server[0].public_ip}","${aws_instance.nomad-server[1].public_ip}","${aws_instance.nomad-server[2].public_ip}"]
}

# Create AWS Network Components
resource aws_vpc "nomad-demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
   Name = "${var.owner}-vpc"
  }
}

resource aws_subnet "nomad-demo" {
  vpc_id     = aws_vpc.nomad-demo.id
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.owner}-subnet"
  }
}

resource aws_security_group "nomad-demo" {
  name = "${var.owner}-security-group"

  vpc_id = aws_vpc.nomad-demo.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.owner}-security-group"
  }
}

resource aws_internet_gateway "nomad-demo" {
  vpc_id = aws_vpc.nomad-demo.id

  tags = {
    Name = "${var.owner}-internet-gateway"
  }
}

resource aws_route_table "nomad-demo" {
  vpc_id = aws_vpc.nomad-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nomad-demo.id
  }
}

resource aws_route_table_association "nomad-demo" {
  subnet_id      = aws_subnet.nomad-demo.id
  route_table_id = aws_route_table.nomad-demo.id
}

resource aws_instance "nomad-server" {
  count                       = 3
  ami                         = data.aws_ami.nomad-demo.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.nomad-demo.id
  vpc_security_group_ids      = [aws_security_group.nomad-demo.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  user_data                   = templatefile("server_template.tpl",{server_name_tag="${var.owner}-nomad-server-instance"})
  tags = {
    Name = "${var.owner}-nomad-server-instance"
    Owner = var.owner_tag
  }
}

resource aws_instance "nomad-client" {
  count                       = 4
  ami                         = data.aws_ami.nomad-demo.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.nomad-demo.id
  vpc_security_group_ids      = [aws_security_group.nomad-demo.id]
  // user_data                   = templatefile("client_template.tpl",{server_address="${join(",", aws_instance.nomad-server.*.public_ip)}"})
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  tags = {
    Name = "${var.owner}-nomad-client-instance-${count.index}"
    Owner = var.owner_tag
  }
}

# Nomad EBS Volumes
resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.owner
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.owner
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "sharing_volumes" {
  name   = "sharing_volumes"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.sharing_volumes.json
}

data "aws_iam_policy_document" "sharing_volumes" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeVolume*",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      ]
     resources = ["*"]
  }
}

# EFS Volume
resource "aws_efs_file_system" "nomad_efs" {
  tags = {
    Name = var.owner
  }
}
resource "aws_efs_mount_target" "nomad-mount" {
  file_system_id = aws_efs_file_system.nomad_efs.id
  subnet_id      = aws_subnet.nomad-demo.id
  security_groups = [aws_security_group.nomad-demo.id]
}

output "efs_volume" {
      value = <<EOM
  # volume registration
  type = "csi"
  id = "efs-volume"
  name = "efs-volume"
  external_id = "${aws_efs_file_system.nomad_efs.id}"
  access_mode = "multi-node-multi-writer"
  attachment_mode = "file-system"
  plugin_id = "aws-efs"
  EOM
}

#Nomad Storage Jobs
resource "time_sleep" "wait_for_nomad" {
  create_duration = "60s"

  triggers = {
    # This sets up a proper dependency on the RAM association
    server_cluster = "${join(",", aws_instance.nomad-server.*.public_ip)}"
  }
}

provider "nomad" {
  address = "http://${aws_instance.nomad-server[0].public_ip}:4646"
  region  = var.nomad_region
}
resource "nomad_job" "plugin-ebs-controller" {
  jobspec = file("plugin-ebs-controller.nomad")
  depends_on = [time_sleep.wait_for_nomad]
}
resource "nomad_job" "plugin-ebs-nodes" {
  jobspec = file("plugin-ebs-nodes.nomad")
  depends_on = [time_sleep.wait_for_nomad]
}

resource "nomad_job" "plugin-efs-nodes" {
  jobspec = file("plugin-efs-nodes.nomad")
  depends_on = [time_sleep.wait_for_nomad]
}



#################################
### Windows Instance Creation ###
#################################
provider "azurerm" {
  features {}
  version = ">=2.0.0"
}

// Data Sources - should be pulled from variables used for Packer image deployment
data "azurerm_resource_group" "main-rg" {
  name = var.nomad_rg
}

data "azurerm_image" "search" {
  name_regex          = "{$var.owner}*"
  resource_group_name = data.azurerm_resource_group.main-rg.name
}

// Supporting resources.
resource "azurerm_virtual_network" "main" {
  name                = "${var.owner}-network"
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
  name                = "${var.owner}-nic"
  location            = data.azurerm_resource_group.main-rg.location
  resource_group_name = data.azurerm_resource_group.main-rg.name

  ip_configuration {
    name                          = "${var.owner}-private_ip"
    subnet_id                     = azurerm_subnet.internal.id
    public_ip_address_id          = azurerm_public_ip.main-ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.owner}-Machine"
  resource_group_name = data.azurerm_resource_group.main-rg.name
  location            = data.azurerm_resource_group.main-rg.location
  size                = "Standard_F2"
  source_image_id     = data.azurerm_image.search.id
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  // custom_data = "JE1ldGFEYXRhSGVhZGVycyA9IEB7Ik1ldGFkYXRhIj0idHJ1ZSJ9IApJbnZva2UtUmVzdE1ldGhvZCAtTWV0aG9kIEdFVCAtdXJpICJodHRwOi8vMTY5LjI1NC4xNjkuMjU0L21ldGFkYXRhL2luc3RhbmNlL25ldHdvcmsvaW50ZXJmYWNlLzAvaXB2NC9pcGFkZHJlc3MvMC9wdWJsaWNpcD9hcGktdmVyc2lvbj0yMDE3LTAzLTAxJmZvcm1hdD10ZXh0IiAtSGVhZGVycyAkTWV0YURhdGFIZWFkZXJzIAoKTmV3LUl0ZW0gJ0M6XGhhc2hpY29ycFxub21hZC5kXG5vbWFkLWNsaWVudC5oY2wnClNldC1Db250ZW50ICdDOlxoYXNoaWNvcnBcbm9tYWQuZFxub21hZC1jbGllbnQuaGNsJyAnYWR2ZXJ0aXNlIHsnIApTZXQtQ29udGVudCAnQzpcaGFzaGljb3JwXG5vbWFkLmRcbm9tYWQtY2xpZW50LmhjbCcgJyAgIGh0dHA9IiRjbGllbnRfcHVibGljX0lQIicKU2V0LUNvbnRlbnQgJ0M6XGhhc2hpY29ycFxub21hZC5kXG5vbWFkLWNsaWVudC5oY2wnICcgICBycGM9IiRjbGllbnRfcHVibGljX0lQIicKU2V0LUNvbnRlbnQgJ0M6XGhhc2hpY29ycFxub21hZC5kXG5vbWFkLWNsaWVudC5oY2wnICcgICBzZXJmPSIkY2xpZW50X3B1YmxpY19JUCInClNldC1Db250ZW50ICdDOlxoYXNoaWNvcnBcbm9tYWQuZFxub21hZC1jbGllbnQuaGNsJyAnYWR2ZXJ0aXNlIH0nCg=="
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  winrm_listener {
    protocol = "Http"
  }

  os_disk {
    name                 = "${var.owner}-disk"
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