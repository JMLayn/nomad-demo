# Nomad Client Configuration.  Includes Raw_exec which should be in the image but this was just a workaround
sudo cat << EOF > /tmp/nomad-client.hcl
advertise {
    http = "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
    rpc  = "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
    serf = "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
}
client {
    enabled = true
    servers = ["provider=aws tag_key=Name tag_value=${server_name_tag}"]
}
plugin "raw_exec" {
    config {
    enabled = true
    }
}
EOF
sudo mv /tmp/nomad-client.hcl /etc/nomad.d/nomad-client.hcl

# Consul Client Configuration
sudo cat << EOF > tmp/consul-client.hcl
advertise_addr = "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
server = false
bind_addr = "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
retry_join = ["provider=aws tag_key=Name tag_value=${server_name_tag}"]
EOF
sudo mv /tmp/consul-client.hcl /etc/consul.d/consul-client.hcl

# Fire Up Services
sudo systemctl start consul
sleep 10
sudo systemctl start nomad