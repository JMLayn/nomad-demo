# Store this as an environment variable in CircleCI
# $setup_vault_token = $env:SETUP_VAULT_TOKEN
# # Packer can provide these values as well
# $setup_vault_addr = $env:SETUP_VAULT_ADDR
# $terraform_version = $env:TERRAFORM_VERSION
# $vault_version = $env:VAULT_VERSION

# Debug variables
# Write-Host "Vault Version:      $vault_version"
# Write-Host "Terraform Version:  $terraform_version"
# Write-Host "Setup Vault Token:  $setup_vault_token"
# Write-Host "Vault Address:      $setup_vault_addr"

# Start by installing Chocolatey and required software
# Write-Host -ForegroundColor Magenta "Installing Chocolatey Packages..."
# Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# choco install cmder -y
# choco install git -y
# # choco install nmap -y # NMAP was causing the powershell script to crap out
# choco install 7zip -y
# choco install putty -y
# choco install openssh -y
# choco install winscp -y
# choco install visualstudiocode -y
# choco install googlechrome -y
# choco install poshgit -y
# choco install jq -y
# choco install azure-cli -y

# # Create a Desktop shortcut for Cmder
# # Note: Set your default shell to Powershell the first time you run this.
# $TargetFile = "C:\tools\cmder\Cmder.exe"
# $ShortcutFile = "C:\Users\Public\Desktop\cmder.lnk"
# $WScriptShell = New-Object -ComObject WScript.Shell
# $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
# $Shortcut.TargetPath = $TargetFile
# $Shortcut.Save()

# Powershell should be able to wget right?
# Force powershell to use a modern version of TLS
Write-Host -ForegroundColor White "Installing Nomad"
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# wget https://releases.hashicorp.com/nomad/0.11.1/nomad_0.11.1_windows_amd64.zip -OutFile C:\Windows\Temp\nomad.zip
Invoke-WebRequest -Uri https://releases.hashicorp.com/nomad/0.11.1/nomad_0.11.1_windows_amd64.zip -OutFile c:\Windows\Temp\nomad.zip
sleep 30
Expand-Archive -Path C:\Windows\Temp\nomad.zip -DestinationPath C:\Windows\System32

# Install Consul
Write-Host -ForegroundColor White "Installing Consul"
Invoke-WebRequest -Uri https://releases.hashicorp.com/consul/1.7.3/consul_1.7.3_windows_amd64.zip -OutFile c:\Windows\Temp\consul.zip
sleep 30
Expand-Archive -Path C:\Windows\Temp\consul.zip -DestinationPath C:\Windows\System32

# Open ports 80 and 443, run RDP on those ports as well as 3389
reg import C:\Users\Public\RDP-Tcp-443.reg
New-NetFirewallRule -DisplayName "Allow Inbound Port 443" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow




Write-Host -ForegroundColor DarkGreen "Setup script complete. Workstation ready for sysprep."