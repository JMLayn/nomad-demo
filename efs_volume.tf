resource "aws_efs_file_system" "nomad_efs" {
  tags = {
    Name = var.prefix
  }
}
resource "aws_efs_mount_target" "nomad-mount" {
  file_system_id = aws_efs_file_system.nomad_efs.id
  subnet_id      = aws_subnet.nomad-demo.id
  security_groups = [aws_security_group.nomad-demo.id]
}

output "efs_volume" {
      value = <<EOM
  # volume registration
  type = "csi"
  id = "efs-volume"
  name = "efs-volume"
  external_id = "${aws_efs_file_system.nomad_efs.id}"
  access_mode = "multi-node-multi-writer"
  attachment_mode = "file-system"
  plugin_id = "aws-efs"
  EOM
}