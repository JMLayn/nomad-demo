job "test-task" {
  datacenters = ["dc1"]
  type        = "batch"
  group "minecraft" {
    volume "efs-tests" {
      type      = "csi"
      read_only = false
      source    = "efs-tests"
    }
    task "example" {
      driver = "exec"
      config {
        command = "/bin/touch"
        args = ["local/test.txt"]
      }
      volume_mount {
          volume      = "efs-tests"
          destination = "/csi"
          read_only   = false
        }
      }
  }
}
