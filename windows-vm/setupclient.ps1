$MetaDataHeaders = @{"Metadata"="true"} 
Invoke-RestMethod -Method GET -uri "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text" -Headers $MetaDataHeaders 

New-Item 'C:\hashicorp\nomad.d\nomad-client.hcl'
Set-Content 'C:\hashicorp\nomad.d\nomad-client.hcl' 'advertise {' 
Set-Content 'C:\hashicorp\nomad.d\nomad-client.hcl' '   http="$client_public_IP"'
Set-Content 'C:\hashicorp\nomad.d\nomad-client.hcl' '   rpc="$client_public_IP"'
Set-Content 'C:\hashicorp\nomad.d\nomad-client.hcl' '   serf="$client_public_IP"'
Set-Content 'C:\hashicorp\nomad.d\nomad-client.hcl' 'advertise }'
