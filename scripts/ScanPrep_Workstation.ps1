<#
ScanPrep_Workstation.ps1
Enables WinRM, creates a scan user, and opens firewall ports for lab credentialed scanning.
Run in isolated lab VM only.
#>

New-Item -Path C:\temp -ItemType Directory -Force | Out-Null

# Enable PS Remoting (WinRM)
try {
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    Write-Output "Enabled PowerShell Remoting (WinRM)"
} catch {
    Write-Output "Enable-PSRemoting failed: $_"
}

# Add firewall rules for WinRM, SMB, RPC
New-NetFirewallRule -DisplayName "Allow WinRM (HTTP)" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Any -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow SMB (445)" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow -Profile Any -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow RPC (135)" -Direction Inbound -Protocol TCP -LocalPort 135 -Action Allow -Profile Any -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow NetBIOS (139)" -Direction Inbound -Protocol TCP -LocalPort 139 -Action Allow -Profile Any -ErrorAction SilentlyContinue

# Create a scan user with admin privileges
$scanUser = "scanuser"
$scanPassPlain = "ScanMe123!"
if (-not (Get-LocalUser -Name $scanUser -ErrorAction SilentlyContinue)) {
    $sec = ConvertTo-SecureString $scanPassPlain -AsPlainText -Force
    New-LocalUser -Name $scanUser -Password $sec -FullName "Scanner Account" -Description "Account for Nessus scans"
    Add-LocalGroupMember -Group "Administrators" -Member $scanUser
    Write-Output "Created scan user $scanUser"
} else {
    Write-Output "Scan user already exists"
}

# Ensure WinRM service is running and set to automatic
Set-Service -Name WinRM -StartupType Automatic
Start-Service WinRM

# Export local policy for PolicyAnalyzer
secedit /export /cfg C:\temp\local_policy_for_scan.inf
Write-Output "Exported local policy to C:\temp\local_policy_for_scan.inf"

Write-Output "Scan prep complete. Credentials: $scanUser / $scanPassPlain"
