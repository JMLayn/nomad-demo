source "amazon-ebs" "ubuntu-image" {
  ami_name = "nomad-demo {{timestamp}}"
  region = "us-east-2"
  instance_type = "t2.micro"

  source_ami_filter {
      filters {
        virtualization-type = "hvm"
        name =  "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
        root-device-type = "ebs"
      }
      owners = ["099720109477"]
      most_recent = true
  }
  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu-image"
  ]

  provisioner "file" {
    source      = "files/consul.service"
    destination = "/tmp/consul.service"
  }

  provisioner "file" {
    source      = "files/nomad.service"
    destination = "/tmp/nomad.service"
  }

  provisioner "file" {
    source      = "files/nomad-common.hcl"
    destination = "/tmp/nomad-common.hcl"
  }

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update",
      "sudo apt install unzip -y",
      "sudo apt install nfs-common -y",
      "sudo apt install mysql-client -y",
      "sudo apt install default-jre -y",
      "curl -fsSL \"https://get.docker.com\" -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sleep 30",
      "sudo usermod -aG docker ubuntu",
      "curl -k -O \"https://releases.hashicorp.com/nomad/0.11.1/nomad_0.11.1_linux_amd64.zip\"",
      "curl -k -O \"https://releases.hashicorp.com/consul/1.7.2/consul_1.7.2_linux_amd64.zip\"",
      "unzip consul_1.7.2_linux_amd64.zip",
      "unzip nomad_0.11.1_linux_amd64.zip",
      "sudo mv nomad /usr/local/bin",
      "sudo mv consul /usr/local/bin"
    ]
  }
  provisioner "shell"{
    inline = [
      "sudo /usr/local/bin/consul -autocomplete-install",
      "sudo useradd --system --home /etc/consul.d --shell /bin/false consul",
      "sudo mkdir /etc/consul.d /var/lib/consul/ /var/run/consul/",
      "sudo chown -R consul:consul /etc/consul.d /var/lib/consul/ /var/run/consul/",
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service"
    ]
  }

  provisioner "shell"{
    inline = [
      "sudo /usr/local/bin/nomad -autocomplete-install",
      "sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad",
      "sudo mkdir /etc/nomad.d",
      "sudo chown -R nomad:nomad /etc/nomad.d",
      "sudo mkdir /var/lib/nomad",
      "sudo chown -R nomad:nomad /var/lib/nomad",
      "sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service",
      "sudo mv /tmp/nomad-common.hcl /etc/nomad.d/nomad-common.hcl"
    ]
 }
}
