provider "aws" {
  version = "~> 2.5"
  region  = var.region
}

resource aws_vpc "nomad-demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc"
  }
}

resource aws_subnet "nomad-demo" {
  vpc_id     = aws_vpc.nomad-demo.id
  cidr_block = var.vpc_cidr
  tags = {
    name = "${var.prefix}-subnet"
  }
}

resource aws_security_group "nomad-demo" {
  name = "${var.prefix}-security-group"

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
    Name = "${var.prefix}-security-group"
  }
}

resource aws_internet_gateway "nomad-demo" {
  vpc_id = aws_vpc.nomad-demo.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
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
  ami                         = data.aws_ami.nomad-demo.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.nomad-demo.id
  vpc_security_group_ids      = [aws_security_group.nomad-demo.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  user_data                   = templatefile("server_template.tpl",{})
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
  user_data                   = templatefile("client_template.tpl",{server_address=aws_instance.nomad-server.private_ip})
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  tags = {
    Name = "${var.prefix}-nomad-client-instance-${count.index}"
    Owner = var.owner_tag
  }
}

resource null_resource "local_executions" {
    provisioner "local-exec" {
      command = "export NOMAD_ADDR=http://${aws_instance.nomad-server.public_ip}:4646"
    }
}