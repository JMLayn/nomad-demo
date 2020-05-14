#!/usr/bin/env bash


# Client specific consul configuration grabbing local IP
cat << EOF > /etc/consul.d/consul-client.hcl
server = false
bind_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
retry_join = ["${server_address}"]
EOF

# Starting consul and nomad services
sudo systemctl start consul
sleep 10
sudo systemctl start nomad