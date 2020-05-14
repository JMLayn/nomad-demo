provider "nomad" {
  address = "http://${aws_instance.nomad-server[0].public_ip}:4646"
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