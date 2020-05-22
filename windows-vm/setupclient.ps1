$MetaDataHeaders = @{"Metadata"="true"} 
$client_IP = Invoke-RestMethod -Method GET -uri "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text" -Headers $MetaDataHeaders 

New-Item C:\hashicorp\nomad.d\nomad-client.hcl

@"
advertise {
   http='$client_IP'
   rpc='$client_IP'
   serf='$client_IP'
advertise }
"@ > C:\hashicorp\nomad\nomad.d\nomad-client.hcl 

