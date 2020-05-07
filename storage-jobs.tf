variable "nomad_region" {
  type        = string
  description = "Region of NOMAD server (not AWS Region)"
  default     = "global"
}
provider "nomad" {
  address = "http://${aws_instance.nomad-server.public_ip}:4646"
  region  = var.nomad_region
}
resource "nomad_job" "plugin-ebs-controller" {
  jobspec = file("plugin-ebs-controller.nomad")
}
resource "nomad_job" "plugin-ebs-nodes" {
  jobspec = file("plugin-ebs-nodes.nomad")
}

resource "nomad_job" "plugin-efs-nodes" {
  jobspec = file("plugin-efs-nodes.nomad")
}