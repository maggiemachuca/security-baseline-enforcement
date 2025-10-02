<#
BadPolicy_Workstation.ps1
Purpose: Intentionally weaken a Windows 10/11 workstation for lab testing and remediation practice.
DO NOT RUN OUTSIDE OF AN ISOLATED LAB VM.
#>

# Create temp folder
New-Item -Path C:\temp -ItemType Directory -Force | Out-Null

# Create weak local admin account
$Username = "labuser"
$PasswordPlain = "Password123!"
$SecurePass = ConvertTo-SecureString $PasswordPlain -AsPlainText -Force

if (-not (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $Username -Password $SecurePass -FullName "Lab User" -Description "Temporary lab admin account"
    Add-LocalGroupMember -Group "Administrators" -Member $Username
    Write-Output "Created user $Username with admin privileges"
} else {
    Write-Output "User $Username already exists"
}

# Disable password policy
$inf = @"
[System Access]
MinimumPasswordLength = 0
PasswordComplexity = 0
LockoutBadCount = 0
ResetLockoutCount = 0
LockoutDuration = 0
"@
$inf | Out-File -FilePath C:\temp\weak_pass.inf -Encoding ASCII
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\temp\weak_pass.inf /areas SECURITYPOLICY
Write-Output "Applied weak password policy"

# Enable SMBv1 (if supported)
try {
    Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction Stop
    Write-Output "SMBv1 enabled (if available)"
} catch {
    Write-Output "SMBv1 enable failed or unsupported: $_"
}

# Disable all firewall profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-Output "Disabled all Windows Firewall profiles"

# Enable RDP + Disable NLA
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0 -ErrorAction SilentlyContinue
Write-Output "Enabled RDP and disabled NLA (if supported)"

# Disable Defender real-time protection (if allowed)
try {
    Set-MpPreference -DisableRealtimeMonitoring $true
    Write-Output "Attempted to disable Defender real-time protection"
} catch {
    Write-Output "Defender protection could not be disabled: $_"
}

# Disable audit logging (Logon & Account Logon)
auditpol /set /subcategory:"Logon" /success:disable /failure:disable
auditpol /set /subcategory:"Account Logon" /success:disable /failure:disable
Write-Output "Disabled audit logging for logon events"

# Set PowerShell execution policy to Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
Write-Output "Set PowerShell execution policy to Unrestricted"

# Configure AutoAdminLogon (insecure autologin)
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $Username -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $PasswordPlain -Force
    Write-Output "Configured AutoAdminLogon for $Username"
} catch {
    Write-Output "Failed to configure AutoAdminLogon: $_"
}

# Export local security policy for comparison
secedit /export /cfg C:\temp\local_policy.inf
Write-Output "Exported current local policy to C:\temp\local_policy.inf"

Write-Output "Finished applying bad policy settings. Reboot recommended for full effect."
