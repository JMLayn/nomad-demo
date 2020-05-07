job "minecraft" {
  datacenters = ["dc1"]
  type        = "service"
  group "minecraft" {
    volume "minecraft" {
      type   = "host"
      source = "minecraft"
    }
    // volume "efs-tests" {
    //   type      = "csi"
    //   read_only = false
    //   source    = "efs-tests"
    // }
    task "eula" {
      driver = "exec"
      volume_mount {
        volume      = "minecraft"
        destination = "/var/volume"
        // volume      = "efs-tests"
        // destination = "/csi"
        // read_only   = false
      }
      config {
        command = "mv"
        args    = ["${NOMAD_TASK_DIR}/eula.txt", "/var/volume/"]
      //   command = "mv"
      //   args    = ["local/eula.txt", "/csi/"]
      }
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      template {
        data        = "eula=true"
        destination = "local/eula.txt"
      }
    }
    task "minecraft" {
      driver = "exec"
      config {
        command = "/bin/sh"
        args    = ["-c", "cd /var/volume && exec java -Xms1024M -Xmx2048M -jar /local/server.jar --nogui; while true; do sleep 5; done"]
        // jar_path    = "/var/volume/server.jar"
        // jvm_options = ["-Xmx1024m", "-Xms256m", "nogui"]
      }
      artifact {
        source = "https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar"
        // destination = "/var/volume/server.jar"
      }
      resources {
        cpu    = 2000
        memory = 1492
      }
      volume_mount {
        volume      = "minecraft"
        destination = "/var/volume"
        // volume      = "efs-tests"
        // destination = "/csi"
        // read_only   = false
      }
    }
  }
}
