output "server_ip_addr" {
  value = aws_instance.nomad-server.public_ip
}