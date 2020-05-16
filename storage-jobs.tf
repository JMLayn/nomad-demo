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