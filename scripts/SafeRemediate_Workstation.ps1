<#
SafeRemediate_Workstation.ps1
Purpose: Safely harden a misconfigured Windows workstation without breaking remote access.
Run as Administrator in your lab VM.
#>

New-Item -Path C:\temp -ItemType Directory -Force | Out-Null

Write-Host "[1/10] Enforce safer password & lockout policy..."
$inf = @"
[System Access]
; Password policy
MinimumPasswordLength = 12
PasswordComplexity = 1
MinimumPasswordAge = 1
MaximumPasswordAge = 60

; Account lockout
LockoutBadCount = 5
ResetLockoutCount = 15
LockoutDuration = 15
"@
$infPath = "C:\temp\safe_policy.inf"
$inf | Out-File -FilePath $infPath -Encoding ASCII
secedit /configure /db C:\Windows\security\local.sdb /cfg $infPath /areas SECURITYPOLICY | Out-Null

Write-Host "[2/10] Disable SMBv1 (if present)..."
try {
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction Stop | Out-Null
    Write-Host "  SMBv1 disabled (pending reboot)."
} catch { Write-Host "  SMBv1 disable attempt skipped/unavailable: $($_.Exception.Message)" }

Write-Host "[3/10] Re-enable Microsoft Defender real-time protection..."
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
} catch { Write-Host "  Defender preference set failed/blocked: $($_.Exception.Message)" }

Write-Host "[4/10] Re-enable key audit policies (Logon/Account Logon)..."
auditpol /set /subcategory:"Logon" /success:enable /failure:enable | Out-Null
auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable | Out-Null

Write-Host "[5/10] Restore safer PowerShell execution policy..."
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
} catch { Write-Host "  Execution policy change failed: $($_.Exception.Message)" }

Write-Host "[6/10] Disable AutoAdminLogon and remove stored plaintext password..."
$wl = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $wl -Name "AutoAdminLogon" -Value "0" -Force
Remove-ItemProperty -Path $wl -Name "DefaultPassword" -ErrorAction SilentlyContinue

Write-Host "[7/10] Keep RDP enabled but require NLA..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1 -Force

Write-Host "[8/10] Re-enable Windows Firewall profiles (keep needed rules for scanning)..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
# Ensure inbound rules exist for lab scanning and admin access
$rules = @(
  @{Name="Allow WinRM (HTTP)"; Port=5985},
  @{Name="Allow SMB (445)"; Port=445},
  @{Name="Allow RPC (135)"; Port=135},
  @{Name="Allow NetBIOS (139)"; Port=139},
  @{Name="Allow RDP (3389)"; Port=3389}
)
foreach ($r in $rules) {
  if (-not (Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $r.Name -Direction Inbound -Protocol TCP -LocalPort $r.Port -Action Allow -Profile Any | Out-Null
  }
}

Write-Host "[9/10] Ensure WinRM service is running (for credentialed scans)..."
Set-Service -Name WinRM -StartupType Automatic
Start-Service WinRM

Write-Host "[10/10] Export post-remediation local security policy..."
$afterPath = "C:\temp\local_policy_after_remediation.inf"
secedit /export /cfg $afterPath | Out-Null
Write-Host "  Exported to $afterPath"

Write-Host "Safe remediation complete. A reboot is recommended to finalize settings (SMBv1, etc.)."
