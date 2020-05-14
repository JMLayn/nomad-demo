provider "aws" {
  version = "~> 2.5"
  region  = var.region
}

data aws_ami "nomad-demo" {
  most_recent = true

  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
    #values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    values = ["nomad-demo*"]
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

resource aws_instance "nomad-server" {
  count                       = 3
  ami                         = data.aws_ami.nomad-demo.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.nomad-demo.id
  vpc_security_group_ids      = [aws_security_group.nomad-demo.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  user_data                   = templatefile("server_template.tpl",{server_name_tag="${var.prefix}-nomad-server-instance"})
  tags = {
    Name = "${var.prefix}-nomad-server-instance"
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
    Name = "${var.prefix}-nomad-client-instance-${count.index}"
    Owner = var.owner_tag
  }
}