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
Write-Host -ForegroundColor Magenta "Installing Chocolatey Packages..."
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install cmder -y
choco install git -y
choco install nmap -y
choco install 7zip -y
choco install putty -y
choco install openssh -y
choco install winscp -y
choco install visualstudiocode -y
choco install googlechrome -y
choco install poshgit -y
choco install jq -y
choco install azure-cli -y

# Create a Desktop shortcut for Cmder
# Note: Set your default shell to Powershell the first time you run this.
$TargetFile = "C:\tools\cmder\Cmder.exe"
$ShortcutFile = "C:\Users\Public\Desktop\cmder.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

# Powershell should be able to wget right?
# Force powershell to use a modern version of TLS
Write-Host -ForegroundColor White "Installing Vault and Terraform..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_windows_amd64.zip -OutFile C:\Windows\Temp\vault.zip
wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_windows_amd64.zip -OutFile C:\Windows\Temp\terraform.zip

# Unzip the things
Expand-Archive -Path C:\Windows\Temp\vault.zip -DestinationPath C:\Windows\System32
Expand-Archive -Path C:\Windows\Temp\terraform.zip -DestinationPath C:\Windows\System32

# Open ports 80 and 443, run RDP on those ports as well as 3389
reg import C:\Users\Public\RDP-Tcp-443.reg
New-NetFirewallRule -DisplayName "Allow Inbound Port 443" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow

# Set up integration with the CAM vault server
# This requires an initial token to fetch credentials from Vault
# We also set up our Subscription and Tenant IDs
# Write-Host -ForegroundColor White "Setting Vault token and credentials server..."
# [Environment]::SetEnvironmentVariable("SETUP_VAULT_TOKEN", "$setup_vault_token", "Machine")
# [Environment]::SetEnvironmentVariable("SETUP_VAULT_ADDR", "$setup_vault_addr", "Machine")
# [Environment]::SetEnvironmentVariable("ARM_SUBSCRIPTION_ID", "14692f20-9428-451b-8298-102ed4e39c2a", "Machine")
# [Environment]::SetEnvironmentVariable("ARM_TENANT_ID", "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec", "Machine")

Write-Host -ForegroundColor DarkGreen "Setup script complete. Workstation ready for sysprep."