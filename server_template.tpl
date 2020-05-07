#!/usr/bin/env bash

# Server specific consul configuration grabbing local IP
cat << EOF > /etc/consul.d/consul-server.hcl
server = true
bootstrap_expect = 1
bind_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
client_addr = "0.0.0.0"
ui = true
EOF

# Server specific nomad configuration
cat << EOF > /etc/nomad.d/nomad-server.hcl
bind_addr = "0.0.0.0"
server {
    enabled = true
    bootstrap_expect = 1
}
EOF

# Starting consul and nomad services
sudo systemctl start consul
sleep 10
sudo systemctl start nomad