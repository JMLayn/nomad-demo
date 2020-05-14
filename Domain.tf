data "aws_route53_zone" "selected" {
  name         = "hashidemos.io."
  private_zone = false
}

resource "aws_route53_record" "fqdn" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.prefix}-nomad.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.nomad-server[0].public_ip}","${aws_instance.nomad-server[1].public_ip}","${aws_instance.nomad-server[2].public_ip}"]
}