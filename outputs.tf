output "server_ip_addr" {
  value = aws_instance.nomad-server[*].public_ip
}

output "server_fqdn"{
  value = aws_route53_record.fqdn.name
}