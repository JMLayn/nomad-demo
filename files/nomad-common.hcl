data_dir  = "/var/lib/nomad"

client {
    options {
      docker.privileged.enabled = "true"
    }
  }

plugin "raw_exec" {
  config {
    enabled = true
  }
}

consul {
  address = "127.0.0.1:8500"
}