
resource null_resource "provisioning-clients" {
  for_each = {for client in aws_instance.nomad-client:  client.tags.Name => client}
    # Nomad Client Configuration
    provisioner "remote-exec" {
      inline = [
        "sudo cat << EOF > /tmp/nomad-client.hcl",
        "advertise {",
            "http = \"${each.value.public_ip}\"",
            "rpc  = \"${each.value.public_ip}\"",
            "serf = \"${each.value.public_ip}\"",
        "}",
        "client {",
        "    enabled = true",
        "    servers = [\"${aws_instance.nomad-server[0].public_ip}\",\"${aws_instance.nomad-server[1].public_ip}\",\"${aws_instance.nomad-server[2].public_ip}\"]",
        "}",
        "EOF",
        "sudo mv /tmp/nomad-client.hcl /etc/nomad.d/nomad-client.hcl",
      ]
    }
    # Consul Client Configuration
    provisioner "remote-exec" {
      inline = [
        "sudo cat << EOF > /tmp/consul-client.hcl",
        "advertise_addr = \"${each.value.public_ip}\"",
        "server = false",
        "bind_addr = \"${each.value.private_ip}\"",
        "retry_join = [\"${aws_instance.nomad-server[0].public_ip}\",\"${aws_instance.nomad-server[1].public_ip}\",\"${aws_instance.nomad-server[2].public_ip}\"]",
        "EOF",
        "sudo mv /tmp/consul-client.hcl /etc/consul.d/consul-client.hcl",
      ]
    }
    # Fire Up Services
    provisioner "remote-exec" {
      inline = [
        "sudo systemctl start consul",
        "sleep 10",
        "sudo systemctl start nomad",
      ]
    }
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("${var.ssh_key}")
      host     = each.value.public_ip
    }
}
