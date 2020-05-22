$MetaDataHeaders = @{"Metadata"="true"} 
$client_IP = Invoke-RestMethod -Method GET -uri "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text" -Headers $MetaDataHeaders 
$private_IP =  Invoke-RestMethod -Method GET -uri "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/ipaddress?api-version=2017-03-01&format=text" -Headers $MetaDataHeaders 
$server_1
$server_2
$server_3

New-Item C:\hashicorp\nomad\nomad.d\nomad-client.hcl

@"
advertise {
   http='$client_IP'
   rpc='$client_IP'
   serf='$client_IP'
}

client {
    enabled = true
    servers = ["$server_1,$server_2,$server_3"]
}
plugin "raw_exec" {
    config {
    enabled = true
    }
}
"@ > C:\hashicorp\nomad\nomad.d\nomad-client.hcl 

# Consul Client Configuration
New-Item C:\hashicorp\consul\consul.d\consul-client.hcl
@"
advertise_addr = '$client_IP'
server = false
bind_addr = '$private_IP'
retry_join = ["$server_1,$server_2,$server_3"]
"@ > C:\hashicorp\consul\consul.d\consul-client.hcl

sc.exe create "Consul" binPath= "c:\hashicorp\consul\consul.exe agent -config-dir=C:\hashicorp\consul\consul.d\ -data-dir=C:\hashicorp\consul\consul-data\ -log-file=C:\hashicorp\consul\consul-logs\" start= auto
sc.exe start "Consul"
sc.exe create "Nomad" binPath= "c:\hashicorp\nomad\nomad.exe agent -config=C:\hashicorp\nomad\nomad.d\ -data-dir=C:\hashicorp\nomad\nomad-data\" start= auto
sc.exe start "Nomad"